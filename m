Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 343066B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 04:09:59 -0400 (EDT)
Date: Mon, 5 Aug 2013 17:10:08 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/4] mm, page_alloc: add likely macro to help compiler
 optimization
Message-ID: <20130805081008.GF27240@lge.com>
References: <1375409279-16919-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20130802162722.GA29220@dhcp22.suse.cz>
 <20130802204710.GX715@cmpxchg.org>
 <20130802213607.GA4742@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130802213607.GA4742@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

Hello, Michal.

On Fri, Aug 02, 2013 at 11:36:07PM +0200, Michal Hocko wrote:
> On Fri 02-08-13 16:47:10, Johannes Weiner wrote:
> > On Fri, Aug 02, 2013 at 06:27:22PM +0200, Michal Hocko wrote:
> > > On Fri 02-08-13 11:07:56, Joonsoo Kim wrote:
> > > > We rarely allocate a page with ALLOC_NO_WATERMARKS and it is used
> > > > in slow path. For making fast path more faster, add likely macro to
> > > > help compiler optimization.
> > > 
> > > The code is different in mmotm tree (see mm: page_alloc: rearrange
> > > watermark checking in get_page_from_freelist)
> > 
> > Yes, please rebase this on top.
> > 
> > > Besides that, make sure you provide numbers which prove your claims
> > > about performance optimizations.
> > 
> > Isn't that a bit overkill?  We know it's a likely path (we would
> > deadlock constantly if a sizable portion of allocations were to ignore
> > the watermarks).  Does he have to justify that likely in general makes
> > sense?
> 
> That was more a generic comment. If there is a claim that something
> would be faster it would be nice to back that claim by some numbers
> (e.g. smaller hot path).
> 
> In this particular case, unlikely(alloc_flags & ALLOC_NO_WATERMARKS)
> doesn't make any change to the generated code with gcc 4.8.1 resp.
> 4.3.4 I have here.
> Maybe other versions of gcc would benefit from the hint but changelog
> didn't tell us. I wouldn't add the anotation if it doesn't make any
> difference for the resulting code.

Hmm, Is there no change with gcc 4.8.1 and 4.3.4?

I found a change with gcc 4.6.3 and v3.10 kernel.

   text	   data	    bss	    dec	    hex	filename
     35683	   1461	    644	  37788	   939c	page_alloc_base.o
     35715	   1461	    644	  37820	   93bc	page_alloc_patch.o

Slightly larger (32 bytes) than before.
And assembly code looks different as I expected.

* Original code

 17126 .LVL1518:
 17127         .loc 2 1904 0 is_stmt 1                                                                
 17128         testb   $4, -116(%rbp)  #, %sfp
 17129         je      .L866   #,

(snip)

 17974 .L866:
 17975 .LBE6053:
 17976 .LBE6052:
 17977 .LBE6051:
 17978 .LBE6073:                                                                                      
 17979 .LBE6093:                                                                                      
 17980 .LBB6094:
 17981         .loc 2 1908 0 
 17982         movl    -116(%rbp), %r14d       # %sfp, D.42080
 17983         .loc 2 1909 0
 17984         movl    -116(%rbp), %r8d        # %sfp,
 17985         movq    %rbx, %rdi      # prephitmp.1723,
 17986         movl    -212(%rbp), %ecx        # %sfp,
 17987         movl    -80(%rbp), %esi # %sfp,
 17988         .loc 2 1908 0
 17989         andl    $3, %r14d       #, D.42080
 17990         movslq  %r14d, %rax     # D.42080, D.42080
 17991         movq    (%rbx,%rax,8), %r13     # prephitmp.1723_268->watermark, mark
 17992 .LVL1591:
 17993         .loc 2 1909 0
 17994         movq    %r13, %rdx      # mark,
 17995         call    zone_watermark_ok       #

On 17129 line, we check ALLOC_NO_WATERMARKS and if not matched, then jump to L866.
L866 is on 17981 line.

* Patched code

 17122 .L807:
 17123 .LVL1513:
 17124         .loc 2 1904 0 is_stmt 1
 17125         testb   $4, -88(%rbp)   #, %sfp
 17126         jne     .L811   #,
 17127 .LBB6092:
 17128         .loc 2 1908 0
 17129         movl    -88(%rbp), %r13d        # %sfp, D.42082
 17130         .loc 2 1909 0
 17131         movl    -88(%rbp), %r8d # %sfp,
 17132         movq    %rbx, %rdi      # prephitmp.1723,
 17133         movl    -160(%rbp), %ecx        # %sfp,
 17134         movl    -80(%rbp), %esi # %sfp,
 17135         .loc 2 1908 0
 17136         andl    $3, %r13d       #, D.42082
 17137         movslq  %r13d, %rax     # D.42082, D.42082
 17138         movq    (%rbx,%rax,8), %r12     # prephitmp.1723_270->watermark, mark
 17139 .LVL1514:
 17140         .loc 2 1909 0
 17141         movq    %r12, %rdx      # mark,
 17142         call    zone_watermark_ok       #

On 17124 line, we check ALLOC_NO_WATERMARKS (0x4) and if not matched,
execute following code without jumping. This is effect of 'likely' macro.
Isn't it reasonable?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
