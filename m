Received: from mate.bln.innominate.de (cerberus.innominate.de [212.84.234.251])
	by hermes.mixx.net (Postfix) with ESMTP id B30B7F814
	for <linux-mm@kvack.org>; Sat, 12 Aug 2000 20:49:57 +0200 (CEST)
Received: from gimli (gimli.bln.innominate.de [10.0.0.90])
	by mate.bln.innominate.de (Postfix) with SMTP id 3E6112CA6F
	for <linux-mm@kvack.org>; Sat, 12 Aug 2000 20:49:56 +0200 (CEST)
From: Daniel Phillips <phillips@innominate.de>
Subject: Syncing the page cache
Date: Sat, 12 Aug 2000 20:42:27 +0200
Content-Type: text/plain
MIME-Version: 1.0
Message-Id: <00081220495601.15321@gimli>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, this is my first appearance on this list.  I was spelunking through the VFS and 
I came up against something that was a problem before (in 2.2.13) and it seems
to be even more of a problem now.  In short, it seems like sync doesn't, and 
even if it did, it wouldn't be doing the right thing.  Here's a (edited) log from 
#kernelnewbies that states the problem as clearly as anything I could write 
from scratch:

<surf>	riel, question: I'm a filesystem, and I need a mm call that forces all dirty pages currently 
	mapped to my files (by file_write) through to my blocks - is there something like that now?  
<riel>	surf: I guess so ... otherwise you couldn't unmount filesystems ;) 
<surf>	riel, good observation, I just have to make sure it can be called without the unmount 
<cesarb>	surf: I think it's the same one as the one sync(1) uses... 
<surf>	cesarb, that one was really screwed up when I tried to use it back in 2.2.13 
<surf>	ok, cesarb, I'll check it 
<surf>	riel, ok, it's still as I feared - this is still all done by sync_buffers which just doesn't know
	what to do.
<surf>	riel, this is the same problem as the ->flush you're working on, it's the flip side of it

<surf>	ok, anyone who's interested, the problem with sync_buffers is that it
	trys to guess  which pages need synching just by looking at the buffer lists. 
	It can't possibly know from  that - it's *going* to do the wrong thing
<surf>	worse: file_fsync syncs all the buffers of a file but does not sync pages that may be 
	mapped to them - somebody tell me how this is ever going to work
<surf>	ak, I'm beginning to suspect that sync is no sync at all.  Unless I've really missed 
	something...

<surf>	riel, the sync code in VFS looks braindamaged - doesn't seem to do anything to the page 
	cache at all
<riel> 	surf: that's true
<riel> 	surf: until now all dirty pages are in the buffer lists
<surf> 	well, what about dirty pages?
<riel> 	surf: we need to change that and have a dirty page list
<surf> 	yes
<surf> 	please allow me to have some input :-)
<surf> 	because, I need to have some pretty specifc control, of the type I mentioned  before...  
<riel> 	surf: subscribe to linux-mm@kvack.org, if you haven't already done so ;)   
<surf> 	riel, ok

OK, there's the problem.  At least, I think it's a problem.  I'm not proposing any 
specific solution yet, and truthfully, I haven't thought enough about what the ideal
solution would be.  I thought I'd start by stating the problem...

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
