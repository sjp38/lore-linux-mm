Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	HTML_MESSAGE,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7799AC04A6B
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 04:21:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE3C6208C3
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 04:21:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE3C6208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BA636B0003; Tue, 14 May 2019 00:21:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56D4F6B0005; Tue, 14 May 2019 00:21:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 459506B0007; Tue, 14 May 2019 00:21:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 071706B0003
	for <linux-mm@kvack.org>; Tue, 14 May 2019 00:21:09 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id c12so11110469pfb.2
        for <linux-mm@kvack.org>; Mon, 13 May 2019 21:21:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language;
        bh=NP+3O/0LttVJ8QsrYDmvw75XaNtX6CD38Fq1+X8Q3zs=;
        b=oxuDutWtyusfXzh9hcmWnmT07V7/0KV9KSxUjD5Psqajw+6BWXEx/DPnfwz3B5h/39
         LqYAXg4AT+7CTyK8AsAT3cNMHHXZOF7VMn0QBrqK98kB5a0r7ahmJ7TjGeZ39bFJZVGB
         h/zPOXIGcwc+yhgWvsgFU4zzftQwo3ogruAQzk4R6NFIjeqPtnM7uecE5ctDXZ6ofLXN
         6/CH91ITvW4X7K6VGnAmOB9VylNkxOg6jQWd3HfMyWPzp36ZWx8NBB66jyDaTxg8Rzj/
         comZYrpQPeVLB/Cms34LSXClyWkPhp4x5Xbj6l+SErNcV/m3fzl4wZ40IG0b5JVJXi1g
         xK2Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXhe4XEimGhMR0fWdTqjC8QpsVVX3xAIpBvyZt4G/mzCFeU0XN+
	FYjPTxAxeRzm2VqPHA8NzBo8YES0TyNUtOdQl/R3PqW+nZ3DH+INpJr6icD149Caq6xTV+d2EKA
	ILxteuDjg9bcq0zUQJbubdGY/hYVazuJeG8JUGEsdT1ugWjxtv/ShwJSIV2D5Ap0VtQ==
X-Received: by 2002:a17:902:3281:: with SMTP id z1mr34877375plb.44.1557807668680;
        Mon, 13 May 2019 21:21:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/D1KDPUf1I2qxG1ZbeNmhaDTJjRBnzJzPOo4XABhw2XcCkiaRcWpVinnHFcvfyxVYM9DJ
X-Received: by 2002:a17:902:3281:: with SMTP id z1mr34877317plb.44.1557807667837;
        Mon, 13 May 2019 21:21:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557807667; cv=none;
        d=google.com; s=arc-20160816;
        b=xlRC66cYsXYUZf9RPbK3EfUKv4aG6bitHqvH3AtkaNYPM5qliPNh5TgGAqDLr7Hq6g
         OhMblqcOeRVj0WalrHua1cXsvcCZ08CN2/+/0XEjyZievFhrGmyIygxTvCL8ucS5pWEY
         HLn8jmtLoMEqM31h0/xc9pos/ckqIdUf9g1RIlLRYCrPLd/33E+rFYEaszkqZpyF3IYD
         St5pcGG+hTOUbRhZDjwk5RSvBKU7V+IJwF58HEKFejyzWoaIK7qNTlPxZ7AhfTzzy2kv
         WF9b82DU6uMRCjhICrpT+4+eoEk3rrsIVzpFvnoAjF4IuQviwSFOouzfqijpLvdoCeJn
         JRRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:in-reply-to:mime-version:user-agent:date
         :message-id:from:references:cc:to:subject;
        bh=NP+3O/0LttVJ8QsrYDmvw75XaNtX6CD38Fq1+X8Q3zs=;
        b=XW0Z2B+c6givo3IscazEb/jwWTw4MBVzEmGInYCRP0lt/PPQv14C+PrbvdkFS0RxEW
         xevXaJYQxUWqbNs0yujInxnIsiihOWzF8qwzo5eDFq2OvN/f9R+muxUBBFwJrl+cdTbI
         Kc3kNsSt/70ZDPmwvwtYBt3fPs0Zqfz3VptBNNNf9U31jpCO4R8NvKSS8bh01EyX7VrD
         oawtomQUktDoOHiJX3YjtpF8MVvPGTj9DvEUyqWBNFPdjufcNjX+TttTEaZpsJJgCrsd
         g80ptivQjmFm5XytoqQgD8MXpTMRkCO3jj4AF3XqcBARgQP+cbUoU99ASvevIRBx9bAL
         Hygw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id f13si20881003pga.385.2019.05.13.21.21.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 21:21:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R131e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TRg3.Bc_1557807658;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TRg3.Bc_1557807658)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 14 May 2019 12:21:01 +0800
Subject: Re: [v2 PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
To: Nadav Amit <namit@vmware.com>
Cc: Will Deacon <will.deacon@arm.com>,
 "jstancek@redhat.com" <jstancek@redhat.com>,
 "peterz@infradead.org" <peterz@infradead.org>,
 "minchan@kernel.org" <minchan@kernel.org>, "mgorman@suse.de"
 <mgorman@suse.de>, "stable@vger.kernel.org" <stable@vger.kernel.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
References: <45c6096e-c3e0-4058-8669-75fbba415e07@email.android.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <fbcc8157-b103-2a29-416e-5c84c6a2554f@linux.alibaba.com>
Date: Mon, 13 May 2019 21:20:51 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <45c6096e-c3e0-4058-8669-75fbba415e07@email.android.com>
Content-Type: multipart/alternative;
 boundary="------------2CF6DA1379A748B5936054C5"
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------2CF6DA1379A748B5936054C5
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit



On 5/13/19 7:01 PM, Nadav Amit wrote:
>
>
> On May 13, 2019 4:01 PM, Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
>
>
>     On 5/13/19 9:38 AM, Will Deacon wrote:
>     > On Fri, May 10, 2019 at 07:26:54AM +0800, Yang Shi wrote:
>     >> diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
>     >> index 99740e1..469492d 100644
>     >> --- a/mm/mmu_gather.c
>     >> +++ b/mm/mmu_gather.c
>     >> @@ -245,14 +245,39 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
>     >>   {
>     >>       /*
>     >>        * If there are parallel threads are doing PTE changes on
>     same range
>     >> -     * under non-exclusive lock(e.g., mmap_sem read-side) but
>     defer TLB
>     >> -     * flush by batching, a thread has stable TLB entry can
>     fail to flush
>     >> -     * the TLB by observing pte_none|!pte_dirty, for example
>     so flush TLB
>     >> -     * forcefully if we detect parallel PTE batching threads.
>     >> +     * under non-exclusive lock (e.g., mmap_sem read-side) but
>     defer TLB
>     >> +     * flush by batching, one thread may end up seeing
>     inconsistent PTEs
>     >> +     * and result in having stale TLB entries.  So flush TLB
>     forcefully
>     >> +     * if we detect parallel PTE batching threads.
>     >> +     *
>     >> +     * However, some syscalls, e.g. munmap(), may free page
>     tables, this
>     >> +     * needs force flush everything in the given range.
>     Otherwise this
>     >> +     * may result in having stale TLB entries for some
>     architectures,
>     >> +     * e.g. aarch64, that could specify flush what level TLB.
>     >>        */
>     >> -    if (mm_tlb_flush_nested(tlb->mm)) {
>     >> -            __tlb_reset_range(tlb);
>     >> -            __tlb_adjust_range(tlb, start, end - start);
>     >> +    if (mm_tlb_flush_nested(tlb->mm) && !tlb->fullmm) {
>     >> +            /*
>     >> +             * Since we can't tell what we actually should have
>     >> +             * flushed, flush everything in the given range.
>     >> +             */
>     >> +            tlb->freed_tables = 1;
>     >> +            tlb->cleared_ptes = 1;
>     >> +            tlb->cleared_pmds = 1;
>     >> +            tlb->cleared_puds = 1;
>     >> +            tlb->cleared_p4ds = 1;
>     >> +
>     >> +            /*
>     >> +             * Some architectures, e.g. ARM, that have range
>     invalidation
>     >> +             * and care about VM_EXEC for I-Cache
>     invalidation, need force
>     >> +             * vma_exec set.
>     >> +             */
>     >> +            tlb->vma_exec = 1;
>     >> +
>     >> +            /* Force vma_huge clear to guarantee safer flush */
>     >> +            tlb->vma_huge = 0;
>     >> +
>     >> +            tlb->start = start;
>     >> +            tlb->end = end;
>     >>       }
>     > Whilst I think this is correct, it would be interesting to see
>     whether
>     > or not it's actually faster than just nuking the whole mm, as I
>     mentioned
>     > before.
>     >
>     > At least in terms of getting a short-term fix, I'd prefer the
>     diff below
>     > if it's not measurably worse.
>
>     I did a quick test with ebizzy (96 threads with 5 iterations) on
>     my x86
>     VM, it shows slightly slowdown on records/s but much more sys time
>     spent
>     with fullmm flush, the below is the data.
>
>     nofullmm                 fullmm
>     ops (records/s) 225606                  225119
>     sys (s) 0.69                        1.14
>
>     It looks the slight reduction of records/s is caused by the
>     increase of
>     sys time.
>
>     >
>     > Will
>     >
>     > --->8
>     >
>     > diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
>     > index 99740e1dd273..cc251422d307 100644
>     > --- a/mm/mmu_gather.c
>     > +++ b/mm/mmu_gather.c
>     > @@ -251,8 +251,9 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
>     >         * forcefully if we detect parallel PTE batching threads.
>     >         */
>     >        if (mm_tlb_flush_nested(tlb->mm)) {
>     > +             tlb->fullmm = 1;
>     >                __tlb_reset_range(tlb);
>     > -             __tlb_adjust_range(tlb, start, end - start);
>     > +             tlb->freed_tables = 1;
>     >        }
>     >
>     >        tlb_flush_mmu(tlb);
>
>
> I think that this should have set need_flush_all and not fullmm.

Thanks for the suggestion. I did a quick test with ebizzy too. It looks 
this is almost same with the v2 patch and slightly better than what Will 
suggested.

nofullmm                 fullmm                need_flush_all
ops (records/s)              225606 225119                   225647
sys (s)                            0.69 1.14                          0.47

If no objection from other folks, I would respin the patch based off 
Nadav's suggestion.




--------------2CF6DA1379A748B5936054C5
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <p><br>
    </p>
    <br>
    <div class="moz-cite-prefix">On 5/13/19 7:01 PM, Nadav Amit wrote:<br>
    </div>
    <blockquote type="cite"
      cite="mid:45c6096e-c3e0-4058-8669-75fbba415e07@email.android.com">
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
      <div dir="auto"><br>
        <div dir="auto"><br>
          <div class="elided-text">On May 13, 2019 4:01 PM, Yang Shi
            <a class="moz-txt-link-rfc2396E" href="mailto:yang.shi@linux.alibaba.com">&lt;yang.shi@linux.alibaba.com&gt;</a> wrote:<br
              type="attribution">
            <blockquote style="margin:0 0 0 0.8ex;border-left:1px #ccc
              solid;padding-left:1ex">
              <div><font size="2"><span style="font-size:11pt">
                    <div><br>
                      <br>
                      On 5/13/19 9:38 AM, Will Deacon wrote:<br>
                      &gt; On Fri, May 10, 2019 at 07:26:54AM +0800,
                      Yang Shi wrote:<br>
                      &gt;&gt; diff --git a/mm/mmu_gather.c
                      b/mm/mmu_gather.c<br>
                      &gt;&gt; index 99740e1..469492d 100644<br>
                      &gt;&gt; --- a/mm/mmu_gather.c<br>
                      &gt;&gt; +++ b/mm/mmu_gather.c<br>
                      &gt;&gt; @@ -245,14 +245,39 @@ void
                      tlb_finish_mmu(struct mmu_gather *tlb,<br>
                      &gt;&gt;   {<!-- --><br>
                      &gt;&gt;       /*<br>
                      &gt;&gt;        * If there are parallel threads
                      are doing PTE changes on same range<br>
                      &gt;&gt; -     * under non-exclusive lock(e.g.,
                      mmap_sem read-side) but defer TLB<br>
                      &gt;&gt; -     * flush by batching, a thread has
                      stable TLB entry can fail to flush<br>
                      &gt;&gt; -     * the TLB by observing
                      pte_none|!pte_dirty, for example so flush TLB<br>
                      &gt;&gt; -     * forcefully if we detect parallel
                      PTE batching threads.<br>
                      &gt;&gt; +     * under non-exclusive lock (e.g.,
                      mmap_sem read-side) but defer TLB<br>
                      &gt;&gt; +     * flush by batching, one thread may
                      end up seeing inconsistent PTEs<br>
                      &gt;&gt; +     * and result in having stale TLB
                      entries.  So flush TLB forcefully<br>
                      &gt;&gt; +     * if we detect parallel PTE
                      batching threads.<br>
                      &gt;&gt; +     *<br>
                      &gt;&gt; +     * However, some syscalls, e.g.
                      munmap(), may free page tables, this<br>
                      &gt;&gt; +     * needs force flush everything in
                      the given range. Otherwise this<br>
                      &gt;&gt; +     * may result in having stale TLB
                      entries for some architectures,<br>
                      &gt;&gt; +     * e.g. aarch64, that could specify
                      flush what level TLB.<br>
                      &gt;&gt;        */<br>
                      &gt;&gt; -    if (mm_tlb_flush_nested(tlb-&gt;mm))
                      {<!-- --><br>
                      &gt;&gt; -            __tlb_reset_range(tlb);<br>
                      &gt;&gt; -            __tlb_adjust_range(tlb,
                      start, end - start);<br>
                      &gt;&gt; +    if (mm_tlb_flush_nested(tlb-&gt;mm)
                      &amp;&amp; !tlb-&gt;fullmm) {<!-- --><br>
                      &gt;&gt; +            /*<br>
                      &gt;&gt; +             * Since we can't tell what
                      we actually should have<br>
                      &gt;&gt; +             * flushed, flush everything
                      in the given range.<br>
                      &gt;&gt; +             */<br>
                      &gt;&gt; +            tlb-&gt;freed_tables = 1;<br>
                      &gt;&gt; +            tlb-&gt;cleared_ptes = 1;<br>
                      &gt;&gt; +            tlb-&gt;cleared_pmds = 1;<br>
                      &gt;&gt; +            tlb-&gt;cleared_puds = 1;<br>
                      &gt;&gt; +            tlb-&gt;cleared_p4ds = 1;<br>
                      &gt;&gt; +<br>
                      &gt;&gt; +            /*<br>
                      &gt;&gt; +             * Some architectures, e.g.
                      ARM, that have range invalidation<br>
                      &gt;&gt; +             * and care about VM_EXEC
                      for I-Cache invalidation, need force<br>
                      &gt;&gt; +             * vma_exec set.<br>
                      &gt;&gt; +             */<br>
                      &gt;&gt; +            tlb-&gt;vma_exec = 1;<br>
                      &gt;&gt; +<br>
                      &gt;&gt; +            /* Force vma_huge clear to
                      guarantee safer flush */<br>
                      &gt;&gt; +            tlb-&gt;vma_huge = 0;<br>
                      &gt;&gt; +<br>
                      &gt;&gt; +            tlb-&gt;start = start;<br>
                      &gt;&gt; +            tlb-&gt;end = end;<br>
                      &gt;&gt;       }<br>
                      &gt; Whilst I think this is correct, it would be
                      interesting to see whether<br>
                      &gt; or not it's actually faster than just nuking
                      the whole mm, as I mentioned<br>
                      &gt; before.<br>
                      &gt;<br>
                      &gt; At least in terms of getting a short-term
                      fix, I'd prefer the diff below<br>
                      &gt; if it's not measurably worse.<br>
                      <br>
                      I did a quick test with ebizzy (96 threads with 5
                      iterations) on my x86 <br>
                      VM, it shows slightly slowdown on records/s but
                      much more sys time spent <br>
                      with fullmm flush, the below is the data.<br>
                      <br>
                                                          
                      nofullmm                 fullmm<br>
                      ops (records/s)             
                      225606                  225119<br>
                      sys (s)                           
                      0.69                        1.14<br>
                      <br>
                      It looks the slight reduction of records/s is
                      caused by the increase of <br>
                      sys time.<br>
                      <br>
                      &gt;<br>
                      &gt; Will<br>
                      &gt;<br>
                      &gt; ---&gt;8<br>
                      &gt;<br>
                      &gt; diff --git a/mm/mmu_gather.c
                      b/mm/mmu_gather.c<br>
                      &gt; index 99740e1dd273..cc251422d307 100644<br>
                      &gt; --- a/mm/mmu_gather.c<br>
                      &gt; +++ b/mm/mmu_gather.c<br>
                      &gt; @@ -251,8 +251,9 @@ void
                      tlb_finish_mmu(struct mmu_gather *tlb,<br>
                      &gt;         * forcefully if we detect parallel
                      PTE batching threads.<br>
                      &gt;         */<br>
                      &gt;        if (mm_tlb_flush_nested(tlb-&gt;mm)) {<!-- --><br>
                      &gt; +             tlb-&gt;fullmm = 1;<br>
                      &gt;                __tlb_reset_range(tlb);<br>
                      &gt; -             __tlb_adjust_range(tlb, start,
                      end - start);<br>
                      &gt; +             tlb-&gt;freed_tables = 1;<br>
                      &gt;        }<br>
                      &gt;   <br>
                      &gt;        tlb_flush_mmu(tlb);<br>
                      <br>
                    </div>
                  </span></font></div>
            </blockquote>
          </div>
          <br>
        </div>
        <div dir="auto">I think that this should have set need_flush_all
          and not fullmm.</div>
      </div>
    </blockquote>
    <br>
    Thanks for the suggestion. I did a quick test with ebizzy too. It
    looks this is almost same with the v2 patch and slightly better than
    what Will suggested.<br>
    <br>
    <font size="2"><span style="font-size:11pt">                                    
        nofullmm                 fullmm                need_flush_all<br>
        ops (records/s)              225606                 
        225119                   225647<br>
        sys (s)                            0.69                       
        1.14                          0.47<br>
        <br>
        If no objection from other folks, I would respin the patch based
        off Nadav's suggestion.<br>
        <br>
        <br>
      </span></font><br>
  </body>
</html>

--------------2CF6DA1379A748B5936054C5--

