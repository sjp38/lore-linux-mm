Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id CC6086B004D
	for <linux-mm@kvack.org>; Thu,  3 May 2012 01:46:14 -0400 (EDT)
Date: Wed, 2 May 2012 22:46:12 -0700 (PDT)
From: Sage Weil <sage@newdream.net>
Subject: Re: [PATCH] vmalloc: add warning in __vmalloc
In-Reply-To: <4FA1D93C.9000306@kernel.org>
Message-ID: <Pine.LNX.4.64.1205022241560.18540@cobra.newdream.net>
References: <1335932890-25294-1-git-send-email-minchan@kernel.org>
 <20120502124610.175e099c.akpm@linux-foundation.org> <4FA1D93C.9000306@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kosaki.motohiro@gmail.com, rientjes@google.com, Neil Brown <neilb@suse.de>, Artem Bityutskiy <dedekind1@gmail.com>, David Woodhouse <dwmw2@infradead.org>, Theodore Ts'o <tytso@mit.edu>, Adrian Hunter <adrian.hunter@intel.com>, Steven Whitehouse <swhiteho@redhat.com>, "David S. Miller" <davem@davemloft.net>, James Morris <jmorris@namei.org>, Alexander Viro <viro@zeniv.linux.org.uk>

On Thu, 3 May 2012, Minchan Kim wrote:
> On 05/03/2012 04:46 AM, Andrew Morton wrote:
> > Well.  What are we actually doing here?  Causing the kernel to spew a
> > warning due to known-buggy callsites, so that users will report the
> > warnings, eventually goading maintainers into fixing their stuff.
> > 
> > This isn't very efficient :(
> 
> 
> Yes. I hope maintainers fix it before merging this.
> 
> > 
> > It would be better to fix that stuff first, then add the warning to
> > prevent reoccurrences.  Yes, maintainers are very naughty and probably
> > do need cattle prods^W^W warnings to motivate them to fix stuff, but we
> > should first make an effort to get these things fixed without
> > irritating and alarming our users.  
> > 
> > Where are these offending callsites?

Okay, maybe this is a stupid question, but: if an fs can't call vmalloc 
with GFP_NOFS without risking deadlock, calling with GFP_KERNEL instead 
doesn't fix anything (besides being more honest).  This really means that 
vmalloc is effectively off-limits for file systems in any 
writeback-related path, right?

sage


> 
> 
> dm:
> __alloc_buffer_wait_no_callback
> 
> ubi:
> ubi_dbg_check_write
> ubi_dbg_check_all_ff
> 
> ext4 :
> ext4_kvmalloc
> 
> gfs2 :
> gfs2_alloc_sort_buffer
> 
> ntfs :
> __ntfs_malloc
> 
> ubifs :
> dbg_dump_leb
> scan_check_cb
> dump_lpt_leb
> dbg_check_ltab_lnum
> dbg_scan_orphans
> 
> mm :
> alloc_large_system_hash
> 
> ceph :
> fill_inode
> ceph_setxattr
> ceph_removexattr
> ceph_x_build_authorizer
> ceph_decode_buffer
> ceph_alloc_middle
> 
> 
> 
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 
> 
> 
> 
> -- 
> Kind regards,
> Minchan Kim
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
