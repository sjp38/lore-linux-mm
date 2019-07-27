Return-Path: <SRS0=PO26=VY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58460C76186
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 03:42:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CEC062084C
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 03:42:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RfLhz37N"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CEC062084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27E116B0003; Fri, 26 Jul 2019 23:42:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22EB78E0003; Fri, 26 Jul 2019 23:42:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 145598E0002; Fri, 26 Jul 2019 23:42:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id BB3B96B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 23:42:10 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id f9so26687739wrq.14
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 20:42:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=GtjXx6dhxxQEndICY3GDSb8+k6lA9ea3LjN2zJWwnzw=;
        b=UJS15wBYF4QMOqobeYJS6l+PC32WYoIwN0wWj4Wmc0NB0rXhnnE1BL4rWcrbsFt1Vi
         ni42OFHSc9othXCrW5xvzQCoxd2rsKWOVpa+tzKgucaxGeWKh5GbcSWnuO1krHq3lXmb
         HYpP1fRo4v/xiNRNb71VuYdHNkVlLk1PpmPHxIicrOKJFQ2ZIQlInDlVFgs8BfRC7lGM
         NG8hT2syfdniANn9JYkvsfDyOFSIbPWz8tVMFDYEzXjIkMJ988mlhBUMXfPx4B1p3yzb
         ccItkuRXI2DTCCWDz3/JAjyPzkDo12c1X7uxX9VuBN9Lix9TWKdFrCnhMosyWYGwsNns
         BRDw==
X-Gm-Message-State: APjAAAX5z7/a5szYj0A+JNMktlJBCEbri35+VmJATRJzX+dpDFNUN4m4
	8rWJPwdsGwzYEV9aFzbJKa+/6+LxlNSGqg00K/eK8+E8kXiWa6THLyclPzL7PurXuNcERRxbUuI
	DKbBGZIPVLgvjCEtUwix9cn7/v/MMfWN/X/7j77WVh0IliAEcyToretXFNY6bYA9tag==
X-Received: by 2002:a1c:d10c:: with SMTP id i12mr87786243wmg.152.1564198929964;
        Fri, 26 Jul 2019 20:42:09 -0700 (PDT)
X-Received: by 2002:a1c:d10c:: with SMTP id i12mr87786161wmg.152.1564198928851;
        Fri, 26 Jul 2019 20:42:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564198928; cv=none;
        d=google.com; s=arc-20160816;
        b=xUT/RIqG4Ae04hItain8QB1wtnziaP23ovmDMtyqcDqy/QUQksiSu2m3wnDnNvBzIL
         MWytvPbOPyWIYRDIB898ebHLE6fe3EIn507lX+2wedlCG/PGjuO8kUh1098PkL52cLUF
         OAF5HkYMCjQb/EXRHoz0RgFYEEOdEA1tpy5V9Rjp56WGp3vyuonE4qcxPP+bb5I8bRFN
         dnXYnUd8fLXStEJVk4TvkhuT7uVQhjkSe4Sa0iBFm3PiYcrFywj1eIyGsNatHDVSolNE
         y5l2QrORKtIDXdNCfPQWW/xTuay5O30El6hDuyGRLYUpZREsmlWsfpnGYWzToOrKmPHn
         /e/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=GtjXx6dhxxQEndICY3GDSb8+k6lA9ea3LjN2zJWwnzw=;
        b=LbCG3Dn5Q+kfodJ7XIcFIvMVgxmxJwGQRVlstRupNuwJRUN8jo4ygseAnue16B5kl/
         1PVuRh9Nq8Vez8jHlS/uaiwSxufLskK65v8DxlVh1xXCTDwr4CQ4qSoXFEZ7Gm37/y+C
         fjwIT8pKIRDkD/F7G+f9ns0GyzcDNVJgFOjdP7VUpK6oi9YHmgMbUoQSnbBnV6JTcFCe
         xk8N2qwImWZ01NFW6wMilbJTYAK9d9gAqAPY1u7rG/Oy/IiB/q1MCFtICSFcruB2SNVd
         I8VOqytpwDjdWEKaE628N9wFKjAi+yFi2jY04xZ+qQ5g2QSDlxIXYsdXBOfh0pAREhUQ
         S/iA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RfLhz37N;
       spf=pass (google.com: domain of natechancellor@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=natechancellor@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h142sor30341831wme.7.2019.07.26.20.42.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 20:42:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of natechancellor@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RfLhz37N;
       spf=pass (google.com: domain of natechancellor@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=natechancellor@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=GtjXx6dhxxQEndICY3GDSb8+k6lA9ea3LjN2zJWwnzw=;
        b=RfLhz37NwYURMNZm6MESuI2ly21oa335WCxlaJEWrFHbYc0IObYHRC+zVUlPL3Te85
         c1Hec55I65/nKVnJNmvqzHheAx41L9N4EVL7ZTXNQznol0E/Aw9fZOKKExDayHF04Dji
         P19z9PbxvvtV+PbOdAbDGowNLfw9z2J6anvsTegXymz5Mxi/uWLl/EMKjHW5uiDNUvF3
         Ug7n/NjwI16zia0RqdsoecdXvCe35FIRz7jNha1WBs52ICEF4kwLkaOKIPB/L7AZWbrj
         pJ2BEnRpmi9lh5FTaZvytr/nWVe3eiG2urR4oExRAfdalkkyByfZ+8VaVS+2mvGGsr2U
         NcIg==
X-Google-Smtp-Source: APXvYqyz/Ub40MgewoA7607MxEBAulrgRZL1AzmGhSYaA5fhJQR+19oIcFOVwCyv2W9hcVfJuEBa/g==
X-Received: by 2002:a1c:6a11:: with SMTP id f17mr81602635wmc.110.1564198927977;
        Fri, 26 Jul 2019 20:42:07 -0700 (PDT)
Received: from archlinux-threadripper ([2a01:4f8:222:2f1b::2])
        by smtp.gmail.com with ESMTPSA id a6sm40904454wmj.15.2019.07.26.20.42.07
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 26 Jul 2019 20:42:07 -0700 (PDT)
Date: Fri, 26 Jul 2019 20:42:05 -0700
From: Nathan Chancellor <natechancellor@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Randy Dunlap <rdunlap@infradead.org>, broonie@kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz,
	mm-commits@vger.kernel.org, sfr@canb.auug.org.au,
	Chris Down <chris@chrisdown.name>
Subject: Re: mmotm 2019-07-24-21-39 uploaded (mm/memcontrol)
Message-ID: <20190727034205.GA10843@archlinux-threadripper>
References: <20190725044010.4tE0dhrji%akpm@linux-foundation.org>
 <4831a203-8853-27d7-1996-280d34ea824f@infradead.org>
 <20190725163959.3d759a7f37ba40bb7f75244e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190725163959.3d759a7f37ba40bb7f75244e@linux-foundation.org>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 04:39:59PM -0700, Andrew Morton wrote:
> On Thu, 25 Jul 2019 15:02:59 -0700 Randy Dunlap <rdunlap@infradead.org> wrote:
> 
> > On 7/24/19 9:40 PM, akpm@linux-foundation.org wrote:
> > > The mm-of-the-moment snapshot 2019-07-24-21-39 has been uploaded to
> > > 
> > >    http://www.ozlabs.org/~akpm/mmotm/
> > > 
> > > mmotm-readme.txt says
> > > 
> > > README for mm-of-the-moment:
> > > 
> > > http://www.ozlabs.org/~akpm/mmotm/
> > > 
> > > This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> > > more than once a week.
> > > 
> > > You will need quilt to apply these patches to the latest Linus release (5.x
> > > or 5.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
> > > http://ozlabs.org/~akpm/mmotm/series
> > > 
> > 
> > on i386:
> > 
> > ld: mm/memcontrol.o: in function `mem_cgroup_handle_over_high':
> > memcontrol.c:(.text+0x6235): undefined reference to `__udivdi3'
> 
> Thanks.  This?
> 
> --- a/mm/memcontrol.c~mm-throttle-allocators-when-failing-reclaim-over-memoryhigh-fix-fix
> +++ a/mm/memcontrol.c
> @@ -2414,8 +2414,9 @@ void mem_cgroup_handle_over_high(void)
>  	 */
>  	clamped_high = max(high, 1UL);
>  
> -	overage = ((u64)(usage - high) << MEMCG_DELAY_PRECISION_SHIFT)
> -		/ clamped_high;
> +	overage = (u64)(usage - high) << MEMCG_DELAY_PRECISION_SHIFT;
> +	do_div(overage, clamped_high);
> +
>  	penalty_jiffies = ((u64)overage * overage * HZ)
>  		>> (MEMCG_DELAY_PRECISION_SHIFT + MEMCG_DELAY_SCALING_SHIFT);
>  
> _
> 

This causes a build error on arm:


In file included from ../arch/arm/include/asm/div64.h:127,
                 from ../include/linux/kernel.h:18,
                 from ../include/linux/page_counter.h:6,
                 from ../mm/memcontrol.c:25:
../mm/memcontrol.c: In function 'mem_cgroup_handle_over_high':
../include/asm-generic/div64.h:222:28: warning: comparison of distinct pointer types lacks a cast
  222 |  (void)(((typeof((n)) *)0) == ((uint64_t *)0)); \
      |                            ^~
../mm/memcontrol.c:2423:2: note: in expansion of macro 'do_div'
 2423 |  do_div(overage, clamped_high);
      |  ^~~~~~
In file included from ../arch/arm/include/asm/atomic.h:11,
                 from ../include/linux/atomic.h:7,
                 from ../include/linux/page_counter.h:5,
                 from ../mm/memcontrol.c:25:
../include/asm-generic/div64.h:235:25: warning: right shift count >= width of type [-Wshift-count-overflow]
  235 |  } else if (likely(((n) >> 32) == 0)) {  \
      |                         ^~
../include/linux/compiler.h:77:40: note: in definition of macro 'likely'
   77 | # define likely(x) __builtin_expect(!!(x), 1)
      |                                        ^
../mm/memcontrol.c:2423:2: note: in expansion of macro 'do_div'
 2423 |  do_div(overage, clamped_high);
      |  ^~~~~~
In file included from ../arch/arm/include/asm/div64.h:127,
                 from ../include/linux/kernel.h:18,
                 from ../include/linux/page_counter.h:6,
                 from ../mm/memcontrol.c:25:
../include/asm-generic/div64.h:239:22: error: passing argument 1 of '__div64_32' from incompatible pointer type [-Werror=incompatible-pointer-types]
  239 |   __rem = __div64_32(&(n), __base); \
      |                      ^~~~
      |                      |
      |                      long unsigned int *
../mm/memcontrol.c:2423:2: note: in expansion of macro 'do_div'
 2423 |  do_div(overage, clamped_high);
      |  ^~~~~~
In file included from ../include/linux/kernel.h:18,
                 from ../include/linux/page_counter.h:6,
                 from ../mm/memcontrol.c:25:
../arch/arm/include/asm/div64.h:33:45: note: expected 'uint64_t *' {aka 'long long unsigned int *'} but argument is of type 'long unsigned int *'
   33 | static inline uint32_t __div64_32(uint64_t *n, uint32_t base)
      |                                   ~~~~~~~~~~^
cc1: some warnings being treated as errors
make[3]: *** [../scripts/Makefile.build:274: mm/memcontrol.o] Error 1
make[2]: *** [../Makefile:1768: mm/memcontrol.o] Error 2
make[1]: *** [/home/nathan/cbl/linux-next/Makefile:330: __build_one_by_one] Error 2
make: *** [Makefile:179: sub-make] Error 2


I fixed it up like so but no idea if that is the ideal function to use.


diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5c7b9facb0eb..04b621f1cb6b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2419,8 +2419,8 @@ void mem_cgroup_handle_over_high(void)
 	 */
 	clamped_high = max(high, 1UL);
 
-	overage = (u64)(usage - high) << MEMCG_DELAY_PRECISION_SHIFT;
-	do_div(overage, clamped_high);
+	overage = div64_u64((u64)(usage - high) << MEMCG_DELAY_PRECISION_SHIFT,
+			    clamped_high);
 
 	penalty_jiffies = ((u64)overage * overage * HZ)
 		>> (MEMCG_DELAY_PRECISION_SHIFT + MEMCG_DELAY_SCALING_SHIFT);

