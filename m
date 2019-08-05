Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90A02C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 20:16:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D2E020C01
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 20:16:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D2E020C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E68486B0005; Mon,  5 Aug 2019 16:16:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E17A16B0006; Mon,  5 Aug 2019 16:16:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CDFE66B0007; Mon,  5 Aug 2019 16:16:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 825826B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 16:16:54 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y3so52241948edm.21
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 13:16:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QHFs/b3TxawprHE4ZqiwcRPt7vyEv8aH+zt4tAJ3dxk=;
        b=rt+KO74zQKToFbaKuATkh6PkZwUiTlasRUNTLNpyshZqQiUFfh3Jf4a+2efCGkOIMA
         g31kDbVcHy9hry5Wy6bT2gcLJzk6QZM5SORQB+LN+E1jWrYCdq32en2RS3cIw9uaIB9C
         JZcVqj64Z+4gM9ZC2PXRgEoZ7eieDG7sCGE1fyqEeKzvKNdn08nDWRjfyGoA1s+/PPaN
         +cudqxAzvmjs030ABgknaeWa/CRjmqnOFUcjvR3arBT8+02fuTOTESD1zoky3I/Ge5WF
         irbsTk2U6RC1voVsUyVCqRHY4XqYzw8o+potrxX4vn1tMlhY4zquMQJgBOJ89x7UvRJ1
         B9oQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUmqYb18X5dqUZTstl1cjnBSmI0QVg6wUsw4BNt/79WSfRqdZgj
	zGcRt9cdvXrCvBoF1dy04eimpimaCpwCR5N2KuuuIkGVbV4SHEnBXnVCGHtW/LZ5Z7Z03pjlhkG
	/dOOknA6gqsK2RRYeDrT+AC1IpG7AzvDqT4TAXV0edFpNQijbTgqtW96eJyOzTnY=
X-Received: by 2002:a50:fa96:: with SMTP id w22mr179376edr.45.1565036214057;
        Mon, 05 Aug 2019 13:16:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0zd+k9WAc3zkujB10tMlCOcVsKtxyIKB+d7w5PuQUDfm/qgW0bG9Wpd354mpVVaa3EDX3
X-Received: by 2002:a50:fa96:: with SMTP id w22mr179316edr.45.1565036213173;
        Mon, 05 Aug 2019 13:16:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565036213; cv=none;
        d=google.com; s=arc-20160816;
        b=KIdq6sOiI10sVz63dRqJeBwcAeHaHS3cLabGAmEnPBwMcNDEUMxlNw+Q/x0BOWTh31
         +ii55nrVjL/HnnJWc6FNACcmo7uSog6J0A6yC8kczosFWsWdk4QeO8PrRZQq9KwAE1A8
         7Q2reMp2D8JAusiHltFbxUaFdZg6KofyJVREf4Shbd2nb0VdZkw2uwijR+0AqV29ekWt
         YM4xxF2ywf9Q+qDIJO8N58/RYKKDXtt524iK5d8EGL9YbIbMN8rPidPhQ88YHCnqxw5j
         cX5ismJi35+X3FNwvTHhxeCIOYjf4gI3QqTIshmYmtI+eSM/T8yUXA0kdZ/dJl+pzeOa
         mXzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QHFs/b3TxawprHE4ZqiwcRPt7vyEv8aH+zt4tAJ3dxk=;
        b=S0xlHX+BdJFL9MiurK4qGTbQOQ6mBaGMQd9Xn3G4x9qHY4JI0rpGnVBYfpfYPIuSjF
         XYHQ3FP64ofHscwVFJcJw76QUnq05+08kIh7TvxW8+rrvOHW0X4q5LD6nQTsW9BGSbw/
         rYSejwOeOgFLLSnWW9n45lCLaH+FxWggqa1sU8hZ1QgeZBtYfUMftbyPFqhcjVcUpInQ
         FC8NpMxkveEn0TlK0oe8r7MFHvFU62ck3lGLPUP6x/X5slyIEILyqEBoHc1T4r9yi97/
         fc/DkEZAyf9ulcobCjg7llubVK13/z2rJ6PyBxGscW9U7t7UVN/QfNetctkvhzUU72dF
         3N7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t21si28621021edw.253.2019.08.05.13.16.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 13:16:53 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A5C9CAF0C;
	Mon,  5 Aug 2019 20:16:52 +0000 (UTC)
Date: Mon, 5 Aug 2019 22:16:50 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, pankaj.suryawanshi@einfochips.com
Subject: Re: oom-killer
Message-ID: <20190805201650.GT7597@dhcp22.suse.cz>
References: <CACDBo54Jbueeq1XbtbrFOeOEyF-Q4ipZJab8mB7+0cyK1Foqyw@mail.gmail.com>
 <20190805112437.GF7597@dhcp22.suse.cz>
 <0821a17d-1703-1b82-d850-30455e19e0c1@suse.cz>
 <20190805120525.GL7597@dhcp22.suse.cz>
 <CACDBo562xHy6McF5KRq3yngKqAm4a15FFKgbWkCTGQZ0pnJWgw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACDBo562xHy6McF5KRq3yngKqAm4a15FFKgbWkCTGQZ0pnJWgw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 05-08-19 21:04:53, Pankaj Suryawanshi wrote:
> On Mon, Aug 5, 2019 at 5:35 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Mon 05-08-19 13:56:20, Vlastimil Babka wrote:
> > > On 8/5/19 1:24 PM, Michal Hocko wrote:
> > > >> [  727.954355] CPU: 0 PID: 56 Comm: kworker/u8:2 Tainted: P           O  4.14.65 #606
> > > > [...]
> > > >> [  728.029390] [<c034a094>] (oom_kill_process) from [<c034af24>] (out_of_memory+0x140/0x368)
> > > >> [  728.037569]  r10:00000001 r9:c12169bc r8:00000041 r7:c121e680 r6:c1216588 r5:dd347d7c > [  728.045392]  r4:d5737080
> > > >> [  728.047929] [<c034ade4>] (out_of_memory) from [<c03519ac>]  (__alloc_pages_nodemask+0x1178/0x124c)
> > > >> [  728.056798]  r7:c141e7d0 r6:c12166a4 r5:00000000 r4:00001155
> > > >> [  728.062460] [<c0350834>] (__alloc_pages_nodemask) from [<c021e9d4>] (copy_process.part.5+0x114/0x1a28)
> > > >> [  728.071764]  r10:00000000 r9:dd358000 r8:00000000 r7:c1447e08 r6:c1216588 r5:00808111
> > > >> [  728.079587]  r4:d1063c00
> > > >> [  728.082119] [<c021e8c0>] (copy_process.part.5) from [<c0220470>] (_do_fork+0xd0/0x464)
> > > >> [  728.090034]  r10:00000000 r9:00000000 r8:dd008400 r7:00000000 r6:c1216588 r5:d2d58ac0
> > > >> [  728.097857]  r4:00808111
> > > >
> > > > The call trace tells that this is a fork (of a usermodhlper but that is
> > > > not all that important.
> > > > [...]
> > > >> [  728.260031] DMA free:17960kB min:16384kB low:25664kB high:29760kB active_anon:3556kB inactive_anon:0kB active_file:280kB inactive_file:28kB unevictable:0kB writepending:0kB present:458752kB managed:422896kB mlocked:0kB kernel_stack:6496kB pagetables:9904kB bounce:0kB free_pcp:348kB local_pcp:0kB free_cma:0kB
> > > >> [  728.287402] lowmem_reserve[]: 0 0 579 579
> > > >
> > > > So this is the only usable zone and you are close to the min watermark
> > > > which means that your system is under a serious memory pressure but not
> > > > yet under OOM for order-0 request. The situation is not great though
> > >
> > > Looking at lowmem_reserve above, wonder if 579 applies here? What does
> > > /proc/zoneinfo say?
> 
> 
> What is  lowmem_reserve[]: 0 0 579 579 ?

This controls how much of memory from a lower zone you might an
allocation request for a higher zone consume. E.g. __GFP_HIGHMEM is
allowed to use both lowmem and highmem zones. It is preferable to use
highmem zone because other requests are not allowed to use it.

Please see __zone_watermark_ok for more details.

> > This is GFP_KERNEL request essentially so there shouldn't be any lowmem
> > reserve here, no?
> 
> 
> Why only low 1G is accessible by kernel in 32-bit system ?

https://www.kernel.org/doc/gorman/, https://lwn.net/Articles/75174/
and many more articles. In very short, the 32b virtual address space
is quite small and it has to cover both the users space and the
kernel. That is why we do split it into 3G reserved for userspace and 1G
for kernel. Kernel can only access its 1G portion directly everything
else has to be mapped explicitly (e.g. while data is copied).

> My system configuration is :-
> 3G/1G - vmsplit
> vmalloc = 480M (I think vmalloc size will set your highmem ?)

No, vmalloc is part of the 1GB kernel adress space.

-- 
Michal Hocko
SUSE Labs

