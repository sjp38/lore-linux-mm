Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52F78C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 13:59:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09EF526457
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 13:59:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XorbrS9w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09EF526457
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EB556B0005; Mon,  3 Jun 2019 09:59:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8769F6B0006; Mon,  3 Jun 2019 09:59:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EEEB6B0008; Mon,  3 Jun 2019 09:59:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 037C86B0005
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 09:59:51 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id 25so2575122ljs.16
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 06:59:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=vcIulk1/05i3H3O56SoVs73mT/TuSYKU/0fOegYFnxg=;
        b=CfRf7yndWGEr7J4ZDt0/lqImH22OyLt+poBynFGewKWCM9OVX7qCxghkyEFQKaxBOF
         dFS9UCDFrWZlmaZd4eVgYT9MT/d2d/Ws41zeVl7djoZa470u7KFkTS2xtq2A0cL+WRov
         yk/3dkSQN5zEUR1jcImx8jhqGJdDvNuhxcGD5UEYzu79fD7r+cG7gq/qQFhtjgLDJXdY
         Z7to90/OXSKbaynSqEkI00OKOKQzgGBi1tVC7oLDCBhee6G7hxf0DHYlnDQcgYsNfi58
         hZ3/zh3WadBt/SLXwKP3czMR8YEd1zjNi8E9H/SKshbv6wEovsCNSHeK7Aywmlp14rmA
         v4Fw==
X-Gm-Message-State: APjAAAX+TaZR38Ylj7fHD7ENl83RfOeHNcmqaxNjpMcMfpNBLItMzEjw
	CwiY9ooi5wj23YQJA1g+3tOPtzaUCbtdEkDepzHOw7uD7cuAz4cDJJdbVa9muBYv96WWCd9wAJJ
	jWyM03kPm60Lau+dRW60+eCMmMm5kSP0FR4rc10P+N/zcCVqt5cWE/MerKAyD29tv2Q==
X-Received: by 2002:a2e:9ed9:: with SMTP id h25mr3799055ljk.13.1559570390003;
        Mon, 03 Jun 2019 06:59:50 -0700 (PDT)
X-Received: by 2002:a2e:9ed9:: with SMTP id h25mr3798989ljk.13.1559570388852;
        Mon, 03 Jun 2019 06:59:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559570388; cv=none;
        d=google.com; s=arc-20160816;
        b=x8w104Hzt4Kioh0ist9gSV//bNzrTRx1TDEc4+sGNDxzUevHdbpHrIfOtZjmjNOSkt
         Mkgh7YQCfqde5uVnlV3K76AiTNyqgjWGtw7/Vx92w6YCFlnKYv78Wh5ic3pxhbVlTzu2
         w/bv3L2wcc+G/QwU03CXQDSY8CEI6XUdbYur9nPFtbcyq7ZBkLhr/7hSH5+tya7pyX0a
         p5oumw6AByUwXH5CZJ35M8+Qzpf2iLVJePgF0vF5aX04+r0n6qqWumnvjpZDHZiosPmc
         q0pT3iXfzPL9pT9BlMxqD1g/w0Oit2/gVYjxVuYIrmEmdldVoXlhG592UF5T1yKShmOb
         +Thw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=vcIulk1/05i3H3O56SoVs73mT/TuSYKU/0fOegYFnxg=;
        b=sghsVYnWbhbLLjCoyNLWXmIanJrZMIhGB8be27nUsOdzlKvJaCc9R+iulDjB59ckV8
         mJgnuk/ksYIc/tyPlSNVe5Zylss0p32Q/Blp5AhHk2fIuUFmyj78JjnYXYf3H5d7/SFD
         nxEuh6NG6syvilXcVrpiMBRMj4nczFWYKkqoyTwfpapF7PfZfwNJHVCPgD4xOw0fHopw
         ADkkr9B51IveEfkHKVJSd33iDzwjJgeegfvT3nbEmInxZII6eq8IdG3ZJI54pVWTESFe
         0G+YjA4f1bukhxjiDa0tmPGHKOjHFSdNxuIomIGAPlysMB5O42quz+pbrFjk3pCL6/14
         0W1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XorbrS9w;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c19sor8402327ljk.34.2019.06.03.06.59.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 06:59:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XorbrS9w;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=vcIulk1/05i3H3O56SoVs73mT/TuSYKU/0fOegYFnxg=;
        b=XorbrS9wQiwZEHNOg7M/It2oguH2TnWDInhMG/FuFIm7vNvAHIPJbkftW2hAJkqtPt
         j6hRiv+mT4Ywy1NZEoj014JrkmfFJfdSCPjpT/knaO3KuyymgbUJSonYy5jkcz24zqcE
         zuIvxNP3rZKupgoEripEfh7qoi5bzMG4w6Iiz5cA7p/80YvZIDfUU8hHz2QZIqi+A/H5
         P0RdxCSa1nYBFiM1RnViiOoediFY9tm8u7FFhvtAM0dty7DksSwVczire2TYKUzcgjpH
         XpqaCbWf2N/Lkh9SDKp7Q93+GOsApOQE4EbY4zoCT4GHTzSvyVORARr4Z/ZqyQDjVsTI
         XgVw==
X-Google-Smtp-Source: APXvYqyFVBQYnGPoKwtTGlv44NljHekWGJjapzSzxqZN6bY43Dul5qCS1bh6iX6UugirvFhrzxp7Dw==
X-Received: by 2002:a2e:301a:: with SMTP id w26mr4059172ljw.76.1559570388393;
        Mon, 03 Jun 2019 06:59:48 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id c15sm272940lja.79.2019.06.03.06.59.47
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 06:59:47 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Mon, 3 Jun 2019 15:59:39 +0200
To: Krzysztof Kozlowski <krzk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Uladzislau Rezki (Sony)" <urezki@gmail.com>,
	Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	"linux-samsung-soc@vger.kernel.org" <linux-samsung-soc@vger.kernel.org>,
	linux-kernel@vger.kernel.org,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Hillf Danton <hdanton@sina.com>,
	Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>,
	Andrei Vagin <avagin@gmail.com>
Subject: Re: [BUG BISECT] bug mm/vmalloc.c:470 (mm/vmalloc.c: get rid of one
 single unlink_va() when merge)
Message-ID: <20190603135939.e2mb7vkxp64qairr@pc636>
References: <CAJKOXPcTVpLtSSs=Q0G3fQgXYoVa=kHxWcWXyvS13ie73ByZBw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJKOXPcTVpLtSSs=Q0G3fQgXYoVa=kHxWcWXyvS13ie73ByZBw@mail.gmail.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Krzysztof.

On Mon, Jun 03, 2019 at 11:07:46AM +0200, Krzysztof Kozlowski wrote:
> Hi,
> 
> On recent next I see bugs during boot (after bringing up user-space or
> during reboot):
> kernel BUG at ../mm/vmalloc.c:470!
> On all my boards. On QEMU I see something similar, although the
> message is "Internal error: Oops - undefined instruction: 0 [#1] ARM",
> 
> The calltrace is:
> [   34.565126] [<c0275c9c>] (__free_vmap_area) from [<c0276044>]
> (__purge_vmap_area_lazy+0xd0/0x170)
> [   34.573963] [<c0276044>] (__purge_vmap_area_lazy) from [<c0276d50>]
> (_vm_unmap_aliases+0x1fc/0x244)
> [   34.582974] [<c0276d50>] (_vm_unmap_aliases) from [<c0279500>]
> (__vunmap+0x170/0x200)
> [   34.590770] [<c0279500>] (__vunmap) from [<c01d5a70>]
> (do_free_init+0x40/0x5c)
> [   34.597955] [<c01d5a70>] (do_free_init) from [<c01478f4>]
> (process_one_work+0x228/0x810)
> [   34.606018] [<c01478f4>] (process_one_work) from [<c0147f0c>]
> (worker_thread+0x30/0x570)
> [   34.614077] [<c0147f0c>] (worker_thread) from [<c014e8b4>]
> (kthread+0x134/0x164)
> [   34.621438] [<c014e8b4>] (kthread) from [<c01010b4>]
> (ret_from_fork+0x14/0x20)
> 
> Full log here:
> https://krzk.eu/#/builders/1/builds/3356/steps/14/logs/serial0
> https://krzk.eu/#/builders/22/builds/1118/steps/35/logs/serial0
> 
> Bisect pointed to:
> 728e0fbf263e3ed359c10cb13623390564102881 is the first bad commit
> commit 728e0fbf263e3ed359c10cb13623390564102881
> Author: Uladzislau Rezki (Sony) <urezki@gmail.com>
> Date:   Sat Jun 1 12:20:19 2019 +1000
>     mm/vmalloc.c: get rid of one single unlink_va() when merge
> 
I have checked the linux-next. I can confirm it happens because of:
 mm/vmalloc.c: get rid of one single unlink_va() when merge

The problem is that, it has been applied wrongly into linux-next tree
for some reason, i do not why. Probably due to the fact that i based
my work on 5.1/2-rcX, whereas linux-next is a bit ahead of it. If so,
sorry for that.

See below the clean patch for remotes/linux-next/master:

<snip>
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 650c89f38c1e..0ed95b864e31 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -719,9 +719,6 @@ merge_or_add_vmap_area(struct vmap_area *va,
                        /* Check and update the tree if needed. */
                        augment_tree_propagate_from(sibling);

-                       /* Remove this VA, it has been merged. */
-                       unlink_va(va, root);
-
                        /* Free vmap_area object. */
                        kmem_cache_free(vmap_area_cachep, va);

@@ -746,12 +743,11 @@ merge_or_add_vmap_area(struct vmap_area *va,
                        /* Check and update the tree if needed. */
                        augment_tree_propagate_from(sibling);

-                       /* Remove this VA, it has been merged. */
-                       unlink_va(va, root);
+                       if (merged)
+                               unlink_va(va, root);

                        /* Free vmap_area object. */
                        kmem_cache_free(vmap_area_cachep, va);
-
                        return;
                }
        }
-- 
2.11.0
<snip>

Andrew, i am not sure how to proceed with that. Should i send an updated series
based on linux-next tip or you can fix directly that patch?

Thank you!

--
Vlad Rezki

