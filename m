Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 26F446B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 07:01:08 -0400 (EDT)
Message-ID: <1334919662.5879.23.camel@dabdike>
Subject: Re: [PATCH, RFC 0/3] Introduce new O_HOT and O_COLD flags
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Fri, 20 Apr 2012 15:01:02 +0400
In-Reply-To: <alpine.LFD.2.00.1204201120060.27750@dhcp-27-109.brq.redhat.com>
References: <1334863211-19504-1-git-send-email-tytso@mit.edu>
	 <4F912880.70708@panasas.com>
	 <alpine.LFD.2.00.1204201120060.27750@dhcp-27-109.brq.redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukas Czerner <lczerner@redhat.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, Theodore Ts'o <tytso@mit.edu>, linux-fsdevel@vger.kernel.org, Ext4 Developers List <linux-ext4@vger.kernel.org>, linux-mm@kvack.org

On Fri, 2012-04-20 at 11:45 +0200, Lukas Czerner wrote:
> On Fri, 20 Apr 2012, Boaz Harrosh wrote:
> 
> > On 04/19/2012 10:20 PM, Theodore Ts'o wrote:
> > 
> > > As I had brought up during one of the lightning talks at the Linux
> > > Storage and Filesystem workshop, I am interested in introducing two new
> > > open flags, O_HOT and O_COLD.  These flags are passed down to the
> > > individual file system's inode operations' create function, and the file
> > > system can use these flags as a hint regarding whether the file is
> > > likely to be accessed frequently or not.
> > > 
> > > In the future I plan to do further work on how ext4 would use these
> > > flags, but I want to first get the ability to pass these flags plumbed
> > > into the VFS layer and the code points for O_HOT and O_COLD reserved.
> > > 
> > > 
> > > Theodore Ts'o (3):
> > >   fs: add new open flags O_HOT and O_COLD
> > >   fs: propagate the open_flags structure down to the low-level fs's
> > >     create()
> > >   ext4: use the O_HOT and O_COLD open flags to influence inode
> > >     allocation
> > > 
> > 
> > 
> > I would expect that the first, and most important patch to this
> > set would be the man page which would define the new API. 
> > What do you mean by cold/normal/hot? what is expected if supported?
> > how can we know if supported? ....
> 
> Well, this is exactly my concern as well. There is no way anyone would
> know what it actually means a what users can expect form using it. The
> result of this is very simple, everyone will just use O_HOT for
> everything (if they will use it at all).
> 
> Ted, as I've mentioned on LSF I think that the HOT/COLD name is really
> bad choice for exactly this reason. It means nothing. If you want to use
> this flag to place the inode on the faster part of the disk, then just
> say so and name the flag accordingly, this way everyone can use it.
> However for this to actually work we need some fs<->storage interface to
> query storage layout, which actually should not be that hard to do. I am
> afraid that in current form it will suit only Google and Taobao. I would
> really like to have interface to pass tags between user->fs and
> fs<->storage, but this one does not seem like a good start.

I think this is a little unfair.  We already have the notion of hot and
cold pages within the page cache.  The definitions for storage is
similar: a hot block is one which will likely be read again shortly and
a cold block is one that likely won't (ignoring the 30 odd gradations of
in-between that the draft standard currently mandates)

The concern I have is that the notion of hot and cold files *isn't*
propagated to the page cache, it's just shared between the fs and the
disk.  It looks like we could tie the notion of file opened with O_HOT
or O_COLD into the page reclaimers and actually call
free_hot_cold_page() with the correct flag, meaning we might get an
immediate benefit even in the absence of hint supporting disks.

I cc'd linux-mm to see if there might be an interest in this ... or even
if it's worth it: I can also see we don't necessarily want userspace to
be able to tamper with our idea of what's hot and cold in the page
cache, since we get it primarily from the lru lists.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
