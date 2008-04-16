Date: Wed, 16 Apr 2008 09:23:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Warning on memory offline (and possible in usual migration?)
Message-Id: <20080416092334.2dabce2c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0804151227050.1785@schroedinger.engr.sgi.com>
References: <20080414145806.c921c927.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0804141044030.6296@schroedinger.engr.sgi.com>
	<20080415191350.0dc847b6.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0804151227050.1785@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de, Andrew Morton <akpm@linux-foundation.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Apr 2008 12:31:00 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:
> Page migration should stop after 10 retries though? You need to set the RC 
> to another value than -EAGAIN in order to avoid the retries.
> 
> if (page_mapping(page) && !PageUptodate(page)) {
> 	rc = -EBUSY;
> 	goto unlock;
> }
> 
> will stop retries.
> 
will try.

> > Once I use drop_caches, memory offlining works very well.
> > (even under some workload.) If the code I added is bad, plz blame me.
> 
> The retries during page migration may hold off the completion of bringing 
> up a page up to date since the PageLock is repeatedly acquired. So either 
> pass more pages in one go to migrate_pages() or pause once in awhile?
> 
yes, *may*.  But page offlining can be stopped by Ctrl-C.

What I experienced was.
==
%echo offline > /sys/device/system/memoryXXXX/state
...wait for a minute
Ctrl-C
% sync
% sync
% echo offline > /sys/device/system/memoryXXXX/state
...wait for a minute
% echo 3 > /proc/sys/vm/drop_caches
% echo offline > /sys/device/system/memoryXXXX/state
success.
==

I'll see what happens wish -EBUSY but maybe no help...

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
