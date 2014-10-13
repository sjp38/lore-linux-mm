Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id D80ED6B0069
	for <linux-mm@kvack.org>; Mon, 13 Oct 2014 15:07:44 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id hn15so11600908igb.15
        for <linux-mm@kvack.org>; Mon, 13 Oct 2014 12:07:44 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0125.hostedemail.com. [216.40.44.125])
        by mx.google.com with ESMTP id h10si1034015igt.36.2014.10.13.12.07.43
        for <linux-mm@kvack.org>;
        Mon, 13 Oct 2014 12:07:44 -0700 (PDT)
Message-ID: <1413227261.1287.14.camel@joe-AO725>
Subject: Re: [PATCH] mm, debug: mm-introduce-vm_bug_on_mm-fix-fix.patch
From: Joe Perches <joe@perches.com>
Date: Mon, 13 Oct 2014 12:07:41 -0700
In-Reply-To: <20141013185156.GA1959@redhat.com>
References: <5420b8b0.9HdYLyyuTikszzH8%akpm@linux-foundation.org>
	 <1411464279-20158-1-git-send-email-mhocko@suse.cz>
	 <20140923112848.GA10046@dhcp22.suse.cz> <20140923201204.GB4252@redhat.com>
	 <20141013185156.GA1959@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>

On Mon, 2014-10-13 at 14:51 -0400, Dave Jones wrote:
> On Tue, Sep 23, 2014 at 04:12:04PM -0400, Dave Jones wrote:
>  > On Tue, Sep 23, 2014 at 01:28:48PM +0200, Michal Hocko wrote:
>  >  > And there is another one hitting during randconfig. The patch makes my
>  >  > eyes bleed but I don't know about other way without breaking out the
>  >  > thing into separate parts sounds worse because we can mix with other
>  >  > messages then.
>  > 
>  > how about something along the lines of..
>  > 
>  >  bufptr = buffer = kmalloc()
[]
>  > It does introduce an allocation though, which may be problematic
>  > in this situation. Depending how big this gets, perhaps make it static
>  > instead?
> 
> Now that this landed in Linus tree, I took another stab at it.
> Something like this ? (Untested beyond compiling).
> 
> (The diff doesn't really do it justice, it looks a lot easier to read
>  imo after applying).
> 
> There's still some checkpatch style nits, but this should be a lot
> more maintainable assuming it works.
> 
> My one open question is do we care that this isn't reentrant ?
> Do we expect parallel calls to dump_mm from multiple cpus ever ?


> diff --git a/mm/debug.c b/mm/debug.c
[]
> @@ -164,74 +164,85 @@ void dump_vma(const struct vm_area_struct *vma)
>  }
>  EXPORT_SYMBOL(dump_vma);
>  
> +static char dumpmm_buffer[4096];

Given the maximum single printk is 1024 bytes,
a buffer larger than that 1024 bytes is useless.

grep LOG_LINE_MAX


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
