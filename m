Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF446C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 12:51:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9937820C01
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 12:51:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="GjRfl25Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9937820C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C80A8E0012; Wed, 20 Feb 2019 07:51:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 151F58E0002; Wed, 20 Feb 2019 07:51:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F34948E0012; Wed, 20 Feb 2019 07:51:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id ACC1E8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 07:51:48 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id 202so16744897pgb.6
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 04:51:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=jOha2KzOEG9V/5MhHyFHoO8NfVaaMb6gXtQiy42AI/0=;
        b=o6sfdBoJraZqSAaBzKiSn8JXYFDQja1HzZGdoOtD6CGJzi44D7Fx+B5muApwtklY3Z
         vxJ5SLGUNOfCzaz/Kk/535jNO830X6gNIHiDmgad0S7dQqZKmez6UtKvwufL+juRVYt7
         CjZI8NzHne7q48Cc+Syf8ZiFrVw6ltkvSAsEnawVbvlTL/FTjk3gXVHPmlr/gFV5tBHr
         TPxzanjenvnRwiaBl2TGS/bSEZ/EhP9MPSfQQLWpIfODoXhm8jFFmgV8R0GEogzFM0+u
         ZV4EgGq01L9/jMtPECOfbBXqNbbiPEITFj7V1SAuf5C7coP+VTtY7+vRM02CwInEKg1+
         2iCg==
X-Gm-Message-State: AHQUAuYbvP5IHxmEreg4KDptaAFu3rfDxRte/nbvTyOcxRIm34/TH99o
	uWOcpqLkti/GGw+NkfH4nvYEEDTKsgQMcCH0b4XZ5HNJZWC/wQGaiH2kXUkibk/KavbzHclg+SH
	WBioBXlpAxpf9MvJ36ECOBpPxpZKhgDejdbzSE7C22OlUtPyx8QEF4vRjVr1nCz78nPbofzWokG
	Ykmto1ID45XH7rc4hZKIWCwzQZ1VhYy0y7QdCo17JaWdRV10e2r2xlyo1AmQy5C1B91+NlWcVto
	jo79Vb7oN8aPvu5m66qOTY6GRnK0FptqgjygJQNZEPTmNWG2LthtmT/9mMKU5VDZJjk/+AhWJbm
	BkYGVpuKO+EO2I2sXbU0W5GfJ9is6rlkHSA+QyFZ8wNLIEFdIrprIIfcAR2fGCaJCVzPfp84Ha4
	B
X-Received: by 2002:a17:902:e409:: with SMTP id ci9mr13115713plb.221.1550667108145;
        Wed, 20 Feb 2019 04:51:48 -0800 (PST)
X-Received: by 2002:a17:902:e409:: with SMTP id ci9mr13115658plb.221.1550667107214;
        Wed, 20 Feb 2019 04:51:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550667107; cv=none;
        d=google.com; s=arc-20160816;
        b=NVwQOm/vsm22bSPlJvAVkJOijwTXx2c0a6kN0pFwhIIr0tXQPDNjGosAzwkNSKBL8B
         nceNZJupOYaIypNH4hsOZcEDUvMQoJtjhkmNoR3Z4ULFVvE1xJ/cKjg1jF/8y+2AqJXk
         YdKjFse0WjbLTg9A8Emx/6glt4wemLbR7wUhuqEp7CPVyFSBAPIutFnxOwmpoo1wadRh
         fJwap/7ziIJMlDVGYO4JKbCHBdaoOfguG4LG/P2aetpNNf61J2keWv8vv4qRFJArMH9z
         D9SH6IYJ9dqzEejk7ngjvpOr433wHnXX73uQ9Y+Kdh5xNtG8QxqXV/cUTofRkuiU5bWW
         ou8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=jOha2KzOEG9V/5MhHyFHoO8NfVaaMb6gXtQiy42AI/0=;
        b=quZnr6wqtBixiX4ypSa7bZ1OgpeMjd6mRriqdTIW7E4c9aulAIGWLHKwXC26nmDnoe
         t7DA/3TjejQ2n++Mq861XLsbMekQAMyy3CLORxttueEvB9iAhoseUHOHXCXfxOeC5okB
         7ff6JHF1zUYWKyYYhFkPLUg8vl2tPJRBUXepARecChtS7cI1+fzyEn+IcQA57G037fHP
         EkMDtDZWmCy9NoTVqSKoxgHvSCfr0EDY6Hgnz2l8QYnRNE5aL0CK/zYEg81rpFnwNh6A
         GEK7yRmIJihEMJMXX4qKSXOw5fdl7yH6MDbPwWVV2HbtC5sq8enkdU5xMx01iBJ2bajU
         /Kpg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=GjRfl25Y;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b60sor29524636plc.24.2019.02.20.04.51.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 04:51:47 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=GjRfl25Y;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=jOha2KzOEG9V/5MhHyFHoO8NfVaaMb6gXtQiy42AI/0=;
        b=GjRfl25YkgcRLEXe2itWYLfzPzTxs08hcR2Qmw44KjntlvEoAwIwp81DJAniCTc2H4
         SGaGwFBPZNYJumyF7PNb77CtPzGyzc7ighyw9svK/z6zTlU7mQt0+34TIYmnlA+Tz7pe
         R4GUI6A65GhV4ClBuye6S71XRYq3VElnJdPWIc4R5Lfelous94NShkjsmESscPBGJGFl
         tUJqn4WvEGsOnxn/vXnd+YRQYlvqBDzU9eU/WDrhg9SxmPv+3wOIW54edCZHxZfC7eTN
         iViF5SvBsDRbwyPCpD0mw6ArwPnvuOg0zVyO7pwKwWlGfcvsppj9ljS2Ga/6e87iwG3b
         D5QA==
X-Google-Smtp-Source: AHgI3IbgBiZcT1uJ/i5w0+lv8WT7ZfgAXnH3sWorFq2ayrFGES6yl3f3n35c0/JaXpKBMpIC+JiNPz3lMp/VQioBaho=
X-Received: by 2002:a17:902:4124:: with SMTP id e33mr36570627pld.236.1550667106551;
 Wed, 20 Feb 2019 04:51:46 -0800 (PST)
MIME-Version: 1.0
References: <20190220020251.82039-1-cai@lca.pw>
In-Reply-To: <20190220020251.82039-1-cai@lca.pw>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 20 Feb 2019 13:51:35 +0100
Message-ID: <CAAeHK+wp=UtzoNzcnmnef_uMpEMSeXBgKYOJz7V_tZXs-RK+kQ@mail.gmail.com>
Subject: Re: [PATCH] slub: fix a crash with SLUB_DEBUG + KASAN_SW_TAGS
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux Memory Management List <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 3:03 AM Qian Cai <cai@lca.pw> wrote:
>
> In process_slab(), "p = get_freepointer()" could return a tagged
> pointer, but "addr = page_address()" always return a native pointer. As
> the result, slab_index() is messed up here,
>
> return (p - addr) / s->size;
>
> All other callers of slab_index() have the same situation where "addr"
> is from page_address(), so just need to untag "p".
>
>  # cat /sys/kernel/slab/hugetlbfs_inode_cache/alloc_calls
>
> [18868.759419] Unable to handle kernel paging request at virtual address 2bff808aa4856d48
> [18868.767341] Mem abort info:
> [18868.770133]   ESR = 0x96000007
> [18868.773187]   Exception class = DABT (current EL), IL = 32 bits
> [18868.779103]   SET = 0, FnV = 0
> [18868.782155]   EA = 0, S1PTW = 0
> [18868.785292] Data abort info:
> [18868.788170]   ISV = 0, ISS = 0x00000007
> [18868.792003]   CM = 0, WnR = 0
> [18868.794973] swapper pgtable: 64k pages, 48-bit VAs, pgdp = 0000000002498338
> [18868.801932] [2bff808aa4856d48] pgd=00000097fcfd0003, pud=00000097fcfd0003, pmd=00000097fca30003, pte=00e8008b24850712
> [18868.812597] Internal error: Oops: 96000007 [#1] SMP
> [18868.835088] CPU: 3 PID: 79210 Comm: read_all Tainted: G             L    5.0.0-rc7+ #84
> [18868.843087] Hardware name: HPE Apollo 70             /C01_APACHE_MB         , BIOS L50_5.13_1.0.6 07/10/2018
> [18868.852915] pstate: 00400089 (nzcv daIf +PAN -UAO)
> [18868.857710] pc : get_map+0x78/0xec
> [18868.861109] lr : get_map+0xa0/0xec
> [18868.864505] sp : aeff808989e3f8e0
> [18868.867816] x29: aeff808989e3f940 x28: ffff800826200000
> [18868.873128] x27: ffff100012d47000 x26: 9700000000002500
> [18868.878440] x25: 0000000000000001 x24: 52ff8008200131f8
> [18868.883753] x23: 52ff8008200130a0 x22: 52ff800820013098
> [18868.889065] x21: ffff800826200000 x20: ffff100013172ba0
> [18868.894377] x19: 2bff808a8971bc00 x18: ffff1000148f5538
> [18868.899690] x17: 000000000000001b x16: 00000000000000ff
> [18868.905002] x15: ffff1000148f5000 x14: 00000000000000d2
> [18868.910314] x13: 0000000000000001 x12: 0000000000000000
> [18868.915626] x11: 0000000020000002 x10: 2bff808aa4856d48
> [18868.920937] x9 : 0000020000000000 x8 : 68ff80082620ebb0
> [18868.926249] x7 : 0000000000000000 x6 : ffff1000105da1dc
> [18868.931561] x5 : 0000000000000000 x4 : 0000000000000000
> [18868.936872] x3 : 0000000000000010 x2 : 2bff808a8971bc00
> [18868.942184] x1 : ffff7fe002098800 x0 : ffff80082620ceb0
> [18868.947499] Process read_all (pid: 79210, stack limit = 0x00000000f65b9361)
> [18868.954454] Call trace:
> [18868.956899]  get_map+0x78/0xec
> [18868.959952]  process_slab+0x7c/0x47c
> [18868.963526]  list_locations+0xb0/0x3c8
> [18868.967273]  alloc_calls_show+0x34/0x40
> [18868.971107]  slab_attr_show+0x34/0x48
> [18868.974768]  sysfs_kf_seq_show+0x2e4/0x570
> [18868.978864]  kernfs_seq_show+0x12c/0x1a0
> [18868.982786]  seq_read+0x48c/0xf84
> [18868.986099]  kernfs_fop_read+0xd4/0x448
> [18868.989935]  __vfs_read+0x94/0x5d4
> [18868.993334]  vfs_read+0xcc/0x194
> [18868.996560]  ksys_read+0x6c/0xe8
> [18868.999786]  __arm64_sys_read+0x68/0xb0
> [18869.003622]  el0_svc_handler+0x230/0x3bc
> [18869.007544]  el0_svc+0x8/0xc
> [18869.010428] Code: d3467d2a 9ac92329 8b0a0e6a f9800151 (c85f7d4b)
> [18869.016742] ---[ end trace a383a9a44ff13176 ]---
> [18869.021356] Kernel panic - not syncing: Fatal exception
> [18869.026705] SMP: stopping secondary CPUs
> [18870.254279] SMP: failed to stop secondary CPUs 1-7,32,40,127
> [18870.259942] Kernel Offset: disabled
> [18870.263434] CPU features: 0x002,20000c18
> [18870.267358] Memory Limit: none
> [18870.270725] ---[ end Kernel panic - not syncing: Fatal exception ]---
>
> Signed-off-by: Qian Cai <cai@lca.pw>

Reviewed-by: Andrey Konovalov <andreyknvl@google.com>

> ---
>  mm/slub.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/slub.c b/mm/slub.c
> index 4a61959e1887..289c22f1b0c4 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -311,7 +311,7 @@ static inline void set_freepointer(struct kmem_cache *s, void *object, void *fp)
>  /* Determine object index from a given position */
>  static inline unsigned int slab_index(void *p, struct kmem_cache *s, void *addr)
>  {
> -       return (p - addr) / s->size;
> +       return (kasan_reset_tag(p) - addr) / s->size;
>  }
>
>  static inline unsigned int order_objects(unsigned int order, unsigned int size)
> --
> 2.17.2 (Apple Git-113)
>

