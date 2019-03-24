Return-Path: <SRS0=4n/l=R3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 836C5C43381
	for <linux-mm@archiver.kernel.org>; Sun, 24 Mar 2019 02:52:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1562B2171F
	for <linux-mm@archiver.kernel.org>; Sun, 24 Mar 2019 02:52:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="PGoC7uGU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1562B2171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DA916B0003; Sat, 23 Mar 2019 22:52:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 861566B0006; Sat, 23 Mar 2019 22:52:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7298A6B0007; Sat, 23 Mar 2019 22:52:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4F15D6B0003
	for <linux-mm@kvack.org>; Sat, 23 Mar 2019 22:52:52 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id x18so5617987qkf.8
        for <linux-mm@kvack.org>; Sat, 23 Mar 2019 19:52:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=9eg8Ggkliketk9rWWT4BWqvUk/RVQT4Fs2cnQxAkOK8=;
        b=cBKXoxEiHdOy3j+Nx+eQgNRxy0bHS5nvRSmFdOpig4mVPdXABNPQeyjShnCY/+WbqI
         qeZ2sWoEzojYfhZ9YgmNuZ0i1WHVBfuYeWE7AApKLJo0oXQ6DJeRP5UDl1tf2rk9rBki
         WVKwY5sbCPRu4H+58Xc3NRfXfV3xBOpQP8gn20JXO1bIJJOrBaSOHu95mg/vdagG79rS
         rNeUEdeVbACRKlnaG/41q7SC8cWe633cdhc4KWHORooW3rcjMYsHap2rSE9VyOP42mMJ
         NVzJvjNmf2+R6mmJ7mwX5F7KG1dzbYEZ75DyPCm8S9jqEMp9Y9BCpHsx2R+6wKDV8pKs
         TRog==
X-Gm-Message-State: APjAAAWop7v46lJA4YDo3ZbMAktMJggREZcyMdP27CubfADvDtwIV18R
	OZDD+jXvayB9hhRB+fzDTpsTnmy2TlLWsoaINHkB57Epp4bxGMpAGpr8c2qiAje3d6seZQyZpfM
	+yUpjzXMmhJv3Ogeg4aAdLmaT96eWTcK+JZJd2nFRL7ZTYBKKp5xFWsll7Dx8xO85Lw==
X-Received: by 2002:ac8:7607:: with SMTP id t7mr15309058qtq.28.1553395972005;
        Sat, 23 Mar 2019 19:52:52 -0700 (PDT)
X-Received: by 2002:ac8:7607:: with SMTP id t7mr15309027qtq.28.1553395971221;
        Sat, 23 Mar 2019 19:52:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553395971; cv=none;
        d=google.com; s=arc-20160816;
        b=MTpFtX49YAhQUDyggLWBqFHqHRAnDmOC/Pb0ju5vFZ5c1J1B2dlf88Hpezd6hdPUjz
         TPWwZf0LeYNV/bGn721InsHv722st+5Qzeyr4jM42GbSMbTp6JC97S3TmNm+sKP9/LUP
         qegdZBtSrbbIHFNf0dPZbJ3clyPKBXDHBngTf2T1ZHmFHUKDLZdSDfYo/D/6rR9A5Inb
         CheqFyTmMv591zREIM2xfaR1RxB7LPgO5T0SBaa4qbkRE6PVTABSZ3gE0y54A5uC5/PC
         ZJN/GqnO3uJ1wTLfEM9VviZBoZw1reueN/WXGUsJKqjKMCteixs1UBMlKk7YDEeVtd3c
         clww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=9eg8Ggkliketk9rWWT4BWqvUk/RVQT4Fs2cnQxAkOK8=;
        b=GXLnjza2j3wt/NpoghROseFlaQSNotfoK6lV0fZ+yBpVWpIm421F+XWb+TreF+hi1R
         y1zAwhIy0595S9DyYM5CYZ2BFUdprkkNWl3gslTjZp5XAmTGlbOB+wY9DPe/zyyp3eYY
         xnudA8bom7F00K4QKVfLFxtabsXahMZGsLBAlpfkMHwR309yOlJ3bpOx6GowRRflSLlV
         D/6CHtl7c8r3OpuHR6DfZxvM70z5A2rK3TvDFZD8Tynb5fM5M+fyi2419EEUm2xgR88V
         ZKY+CJZvZSbOSB3xGQjcrTKB1GMycgrInKTh48hsBY2ewpcF3e1hMW0v2V6U+e4HD8Io
         crTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=PGoC7uGU;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f127sor8383919qkc.21.2019.03.23.19.52.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 23 Mar 2019 19:52:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=PGoC7uGU;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=9eg8Ggkliketk9rWWT4BWqvUk/RVQT4Fs2cnQxAkOK8=;
        b=PGoC7uGU9WMclydiHaqFax+vk9whgG124d+ARVqJXURVW39i/nycH9OQbM2aDpgaJx
         QKi5cHEmr/RfuebO0B1xiNudFH50SeFwJyyksVd+iEEXwMlQ17uekxroyfxWuezx5Hp7
         t2g+gmX5L64s4pZzPU0X1sBUSgT5jv9IOlXaFNa0UHga0Zsp7Z9hjpgobMoq9/TuVnDp
         CL62iWCVKrf3Ew1lNPWiA8doYm/xlu1L/PyRw5XouH94ABddThV4JpIPMmlC3/QQZSvw
         /SOuwaRtO/WScaOHUjg1gp1fbbWEGsUM5CCIhVqfVeKjAVDeaLoBdnoQil+16rISGPne
         Zhkg==
X-Google-Smtp-Source: APXvYqxbS836YP5TdchT31JZspesYm1jKxf+UOoQY/ynIkamy3WJlTyFNPYWIOr5xsQvqmaXr8PcQw==
X-Received: by 2002:a05:620a:16d1:: with SMTP id a17mr14293638qkn.92.1553395970680;
        Sat, 23 Mar 2019 19:52:50 -0700 (PDT)
Received: from ovpn-120-94.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id n5sm4084155qkk.4.2019.03.23.19.52.49
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 Mar 2019 19:52:50 -0700 (PDT)
Subject: Re: page cache: Store only head pages in i_pages
To: Matthew Wilcox <willy@infradead.org>
Cc: Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org
References: <1553285568.26196.24.camel@lca.pw>
 <20190323033852.GC10344@bombadil.infradead.org>
 <f26c4cce-5f71-5235-8980-86d8fcd69ce6@lca.pw>
 <20190324020614.GD10344@bombadil.infradead.org>
From: Qian Cai <cai@lca.pw>
Message-ID: <897cfdda-7686-3794-571a-ecb8b9f6101f@lca.pw>
Date: Sat, 23 Mar 2019 22:52:49 -0400
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <20190324020614.GD10344@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/23/19 10:06 PM, Matthew Wilcox wrote:
> Thanks for testing.  Kirill suggests this would be a better fix:
> 
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 41858a3744b4..9718393ae45b 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -334,10 +334,12 @@ static inline struct page *grab_cache_page_nowait(struct address_space *mapping,
>  
>  static inline struct page *find_subpage(struct page *page, pgoff_t offset)
>  {
> +	unsigned long index = page_index(page);
> +
>  	VM_BUG_ON_PAGE(PageTail(page), page);
> -	VM_BUG_ON_PAGE(page->index > offset, page);
> -	VM_BUG_ON_PAGE(page->index + compound_nr(page) <= offset, page);
> -	return page - page->index + offset;
> +	VM_BUG_ON_PAGE(index > offset, page);
> +	VM_BUG_ON_PAGE(index + compound_nr(page) <= offset, page);
> +	return page - index + offset;
>  }
>  
>  struct page *find_get_entry(struct address_space *mapping, pgoff_t offset);

This is not even compiled.

If "s/compound_nr/compound_order/", it failed to boot here,

[   56.843236] Unpacking initramfs...
[   56.881979] page:ffff7fe022eb19c0 count:3 mapcount:0 mapping:38ff80080099c008
index:0x0
[   56.890007] ramfs_aops
[   56.890011] name:"lvm.conf"
[   56.892465] flags: 0x17fffffa400000c(uptodate|dirty)
[   56.900318] raw: 017fffffa400000c dead000000000100 dead000000000200
38ff80080099c008
[   56.908066] raw: 0000000000000000 0000000000000000 00000003ffffffff
7bff8008203bcc80
[   56.915812] page dumped because: VM_BUG_ON_PAGE(index + compound_order(page)
<= offset)
[   56.923818] page->mem_cgroup:7bff8008203bcc80
[   56.928180] page allocated via order 0, migratetype Unmovable, gfp_mask
0x100cc2(GFP_HIGHUSER)
[   56.936800]  prep_new_page+0x4e0/0x5e0
[   56.940556]  get_page_from_freelist+0x4cf4/0x50e0
[   56.945265]  __alloc_pages_nodemask+0x738/0x38b8
[   56.949888]  alloc_page_interleave+0x34/0x2f0
[   56.954249]  alloc_pages_current+0xc0/0x150
[   56.958439]  __page_cache_alloc+0x70/0x2f4
[   56.962541]  pagecache_get_page+0x5e4/0xaf0
[   56.966729]  grab_cache_page_write_begin+0x6c/0x98
[   56.971526]  simple_write_begin+0x40/0x308
[   56.975627]  generic_perform_write+0x1d4/0x4e0
[   56.980076]  __generic_file_write_iter+0x294/0x504
[   56.984872]  generic_file_write_iter+0x354/0x594
[   56.989496]  __vfs_write+0x72c/0x8a0
[   56.993076]  vfs_write+0x1ec/0x424
[   56.996481]  ksys_write+0xbc/0x190
[   56.999890]  xwrite+0x38/0x84
[   57.002869] ------------[ cut here ]------------
[   57.007478] kernel BUG at ./include/linux/pagemap.h:342!
[   57.012801] Internal error: Oops - BUG: 0 [#1] SMP
[   57.017584] Modules linked in:
[   57.020636] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 5.1.0-rc1-mm1+ #7
[   57.027239] Hardware name: HPE Apollo 70             /C01_APACHE_MB         ,
BIOS L50_5.13_1.0.6 07/10/2018
[   57.037057] pstate: 60400009 (nZCv daif +PAN -UAO)
[   57.041839] pc : find_get_entry+0x948/0x950
[   57.046013] lr : find_get_entry+0x940/0x950
[   57.050185] sp : 10ff80082600f420
[   57.053489] x29: 10ff80082600f4d0 x28: efff100000000000
[   57.058792] x27: ffff7fe022eb19c8 x26: 0000000000000010
[   57.064095] x25: 0000000000000035 x24: 0000000000000003
[   57.069397] x23: 00000000000000ff x22: 10ff80082600f460
[   57.074700] x21: ffff7fe022eb19c0 x20: 35ff800825f9a050
[   57.080002] x19: 0000000000000000 x18: 0000000000000000
[   57.085304] x17: 0000000000000000 x16: 000000000000000a
[   57.090606] x15: 35ff800825f9a0b8 x14: 0000000000000000
[   57.095908] x13: ffff800825f9a050 x12: 00000000ffffffff
[   57.101210] x11: 0000000000000003 x10: 00000000000000ff
[   57.106512] x9 : e071b95619aca700 x8 : e071b95619aca700
[   57.111814] x7 : 0000000000000000 x6 : ffff1000102d01f4
[   57.117116] x5 : 0000000000000000 x4 : 0000000000000080
[   57.122418] x3 : ffff1000102b84c8 x2 : 0000000000000000
[   57.127720] x1 : 0000000000000004 x0 : ffff100013316b10
[   57.133024] Process swapper/0 (pid: 1, stack limit = 0x(____ptrval____))
[   57.139715] Call trace:
[   57.142153]  find_get_entry+0x948/0x950
[   57.145979]  pagecache_get_page+0x68/0xaf0
[   57.150066]  grab_cache_page_write_begin+0x6c/0x98
[   57.154847]  simple_write_begin+0x40/0x308
[   57.158934]  generic_perform_write+0x1d4/0x4e0
[   57.163368]  __generic_file_write_iter+0x294/0x504
[   57.168150]  generic_file_write_iter+0x354/0x594
[   57.172757]  __vfs_write+0x72c/0x8a0
[   57.176323]  vfs_write+0x1ec/0x424
[   57.179715]  ksys_write+0xbc/0x190
[   57.183107]  xwrite+0x38/0x84
[   57.186066]  do_copy+0x110/0x898
[   57.189284]  write_buffer+0x148/0x1cc
[   57.192937]  flush_buffer+0x94/0x240
[   57.196505]  __gunzip+0x738/0x8f0
[   57.199810]  gunzip+0x18/0x20
[   57.202768]  unpack_to_rootfs+0x358/0x968
[   57.206769]  populate_rootfs+0x120/0x198
[   57.210684]  do_one_initcall+0x544/0xd00
[   57.214597]  do_initcall_level+0x660/0x814
[   57.218684]  do_basic_setup+0x38/0x50
[   57.222337]  kernel_init_freeable+0x25c/0x444
[   57.226686]  kernel_init+0x1c/0x548
[   57.230165]  ret_from_fork+0x10/0x18
[   57.233733] Code: aa1503e0 94034d79 b0016fe0 912c4000 (d4210000)
[   57.240055] ---[ end trace d7c5c3c62a7fa743 ]---
[   57.244664] Kernel panic - not syncing: Fatal exception
[   57.249997] SMP: stopping secondary CPUs
[   57.254417] ---[ end Kernel panic - not syncing: Fatal exception ]---

