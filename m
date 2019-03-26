Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A844AC10F05
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:37:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A2BD20856
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:37:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A2BD20856
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=cn.fujitsu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F298B6B0006; Tue, 26 Mar 2019 05:37:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED9116B0007; Tue, 26 Mar 2019 05:37:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF0F56B0008; Tue, 26 Mar 2019 05:37:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9D1D66B0006
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:37:38 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id f10so1806562plr.18
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 02:37:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Bd76ynOW8t5qJ15Z2zrOroEN/OE6k8BkQ/urwbmDuvg=;
        b=MU8wz2STXM8m8/+EKZabq8AnI8ROAluum8Yk9LwBLGVpMD+M0zHsqPu7wcc+uGNsr4
         1q9kekI54sildnRzNoksWe0iVN1IWy0lW6zv/7PWV1lBVj/avqse+1K4dZXtL/cKLGpA
         BOTCvNivYSGuEmnmCVf+Zoe6ntdmys2vQqI5+9MCiNmKKonGiLYFBUOgF1lfP3dcFAB6
         WFq/qYm/qbRkKWyWeBzFiAqOh2WWjlGAWyEwV6Kj4SZgt4BHZD7I4zk+/QU2JtIaq/lf
         Q1lrTxvfSf38vq2+zrQkbCHU7pfwcnSEPSQRhSJjOBGRu5aI7Sl5JyjFUPGXX1w7nZJL
         rWtQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of fanc.fnst@cn.fujitsu.com designates 183.91.158.132 as permitted sender) smtp.mailfrom=fanc.fnst@cn.fujitsu.com
X-Gm-Message-State: APjAAAVJbzMcabf/PYus5vKGPRNVgnef/pf+7ngtoRpu5dvUmMdrC/VR
	NRaKetsLMPxP8XI5tyT/muemaQI9g+2QH6l02wj6w9hjJUGC2Y8GY6gzC5wI3ovEzSW90KS3gsc
	2URs8yvyiRY+gJ/81I2LKzqfDACr5cVjMibqFXKkNrwoGE3+w/jsp5oPs6Oah3nXoGw==
X-Received: by 2002:aa7:8390:: with SMTP id u16mr28112753pfm.63.1553593058306;
        Tue, 26 Mar 2019 02:37:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyl8Jt5d5VUehdVxAA/Q6SA77jP6f1kqn6xo0rMe8ljNAwCkQVxoA5w2k5gPP1sFyXL77+O
X-Received: by 2002:aa7:8390:: with SMTP id u16mr28112718pfm.63.1553593057587;
        Tue, 26 Mar 2019 02:37:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553593057; cv=none;
        d=google.com; s=arc-20160816;
        b=PBtkFFGsHke0PJZTYcqXXFws4AYpLK/ih9iou5gO+5j7NyppUWFcyo184yQdDmS8nh
         LKCZgf2FS/f1kbNW0gM4rYDlNDQLpNeBDfY7o5OGSZ5ZZZEZAfTXIiJDpb/qBMxKgbN1
         IzPtKEROxUGqYNZDTLSmzzWAJc0lX+hE2Wiy5180uWCJCa0d0SjeIQGckQ0kCp/9jkF2
         wZU/qGxbzag96hwetViMUl4Ftsk8P2ObCowSFXsgWB55s8sgvje/BFc/57wMS7efIHae
         UiahF2Mx0qrlbY9WTEKObdenxbJeJDVPkbUoO+Vze93H9NWM4XhV6xW/d01w8ST+BtFn
         cnNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Bd76ynOW8t5qJ15Z2zrOroEN/OE6k8BkQ/urwbmDuvg=;
        b=E6Irzq95/tddYnOdAqkpNg/wTw2lxAFA7dn2WniH59uhhvC6k1IL/D0Hzfq2zrUUtT
         JQ0vNWK235+aYtJe07xKDyu+LGX70PrBIgJ/T78gcx6LG2B3WwXe31lpTsViNzmMmXzH
         eixp1naxnPq+HEsHP8+M0MaEKhmT7qbdulbWfOZtYUHSSg9Y2FiparIl6RZl7kvzcsyE
         VXcB6LOlLgHFWeVU5TZ/yFm54eVhm/waKZoWrvTY2UKBM6pBCPyYSk0PDczv0FGar6bF
         KCVGqUJfnR6h2qi5YXR2WLfGW6KbJL7VuKoApLWMSMmj99Sf/FjN3OTX7r/C37MzVWB/
         aEkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of fanc.fnst@cn.fujitsu.com designates 183.91.158.132 as permitted sender) smtp.mailfrom=fanc.fnst@cn.fujitsu.com
Received: from heian.cn.fujitsu.com (mail.cn.fujitsu.com. [183.91.158.132])
        by mx.google.com with ESMTP id f7si11714155pgg.234.2019.03.26.02.37.36
        for <linux-mm@kvack.org>;
        Tue, 26 Mar 2019 02:37:37 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of fanc.fnst@cn.fujitsu.com designates 183.91.158.132 as permitted sender) client-ip=183.91.158.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of fanc.fnst@cn.fujitsu.com designates 183.91.158.132 as permitted sender) smtp.mailfrom=fanc.fnst@cn.fujitsu.com
X-IronPort-AV: E=Sophos;i="5.60,271,1549900800"; 
   d="scan'208";a="57729882"
Received: from unknown (HELO cn.fujitsu.com) ([10.167.33.5])
  by heian.cn.fujitsu.com with ESMTP; 26 Mar 2019 17:37:36 +0800
Received: from G08CNEXCHPEKD01.g08.fujitsu.local (unknown [10.167.33.80])
	by cn.fujitsu.com (Postfix) with ESMTP id 7D1B44CD5BD8;
	Tue, 26 Mar 2019 17:37:31 +0800 (CST)
Received: from localhost.localdomain (10.167.225.56) by
 G08CNEXCHPEKD01.g08.fujitsu.local (10.167.33.89) with Microsoft SMTP Server
 (TLS) id 14.3.439.0; Tue, 26 Mar 2019 17:37:36 +0800
Date: Tue, 26 Mar 2019 17:36:42 +0800
From: Chao Fan <fanc.fnst@cn.fujitsu.com>
To: Baoquan He <bhe@redhat.com>
CC: Michal Hocko <mhocko@kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>, <akpm@linux-foundation.org>, <rppt@linux.ibm.com>,
	<osalvador@suse.de>, <willy@infradead.org>, <william.kucharski@oracle.com>
Subject: Re: [PATCH v2 1/4] mm/sparse: Clean up the obsolete code comment
Message-ID: <20190326093642.GD4234@localhost.localdomain>
References: <20190326090227.3059-1-bhe@redhat.com>
 <20190326090227.3059-2-bhe@redhat.com>
 <20190326092324.GJ28406@dhcp22.suse.cz>
 <20190326093057.GS3659@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20190326093057.GS3659@MiWiFi-R3L-srv>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Originating-IP: [10.167.225.56]
X-yoursite-MailScanner-ID: 7D1B44CD5BD8.AC83F
X-yoursite-MailScanner: Found to be clean
X-yoursite-MailScanner-From: fanc.fnst@cn.fujitsu.com
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 26, 2019 at 05:30:57PM +0800, Baoquan He wrote:
>On 03/26/19 at 10:23am, Michal Hocko wrote:
>> On Tue 26-03-19 17:02:24, Baoquan He wrote:
>> > The code comment above sparse_add_one_section() is obsolete and
>> > incorrect, clean it up and write new one.
>> > 
>> > Signed-off-by: Baoquan He <bhe@redhat.com>
>> 
>> Please note that you need /** to start a kernel doc. Other than that.
>
>I didn't find a template in coding-style.rst, and saw someone is using
>/*, others use /**. I will use '/**' instead. Thanks for telling.

How to format kernel-doc comments
---------------------------------

The opening comment mark ``/**`` is used for kernel-doc comments. The
``kernel-doc`` tool will extract comments marked this way. The rest of
the comment is formatted like a normal multi-line comment with a column
of asterisks on the left side, closing with ``*/`` on a line by itself.

See Documentation/doc-guide/kernel-doc.rst for more details.
Hope that can help you.

Thanks,
Chao Fan

>
>> 
>> Acked-by: Michal Hocko <mhocko@suse.com>
>> > ---
>> > v1-v2:
>> >   Add comments to explain what the returned value means for
>> >   each error code.
>> > 
>> >  mm/sparse.c | 15 ++++++++++++---
>> >  1 file changed, 12 insertions(+), 3 deletions(-)
>> > 
>> > diff --git a/mm/sparse.c b/mm/sparse.c
>> > index 69904aa6165b..b2111f996aa6 100644
>> > --- a/mm/sparse.c
>> > +++ b/mm/sparse.c
>> > @@ -685,9 +685,18 @@ static void free_map_bootmem(struct page *memmap)
>> >  #endif /* CONFIG_SPARSEMEM_VMEMMAP */
>> >  
>> >  /*
>> > - * returns the number of sections whose mem_maps were properly
>> > - * set.  If this is <=0, then that means that the passed-in
>> > - * map was not consumed and must be freed.
>> > + * sparse_add_one_section - add a memory section
>> > + * @nid: The node to add section on
>> > + * @start_pfn: start pfn of the memory range
>> > + * @altmap: device page map
>> > + *
>> > + * This is only intended for hotplug.
>> > + *
>> > + * Returns:
>> > + *   0 on success.
>> > + *   Other error code on failure:
>> > + *     - -EEXIST - section has been present.
>> > + *     - -ENOMEM - out of memory.
>> >   */
>> >  int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
>> >  				     struct vmem_altmap *altmap)
>> > -- 
>> > 2.17.2
>> > 
>> 
>> -- 
>> Michal Hocko
>> SUSE Labs
>
>


