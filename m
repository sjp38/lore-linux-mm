Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79AE6C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 12:21:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DFE4243CF
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 12:21:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="Z2k6P15B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DFE4243CF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0C046B0010; Thu, 30 May 2019 08:20:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE4536B026B; Thu, 30 May 2019 08:20:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD2036B026C; Thu, 30 May 2019 08:20:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5E9C16B0010
	for <linux-mm@kvack.org>; Thu, 30 May 2019 08:20:59 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k15so7498346eda.6
        for <linux-mm@kvack.org>; Thu, 30 May 2019 05:20:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=YT3ORHa/ZvJBb9khTyipcwzY8aPEUTPQ5f0pg4jxr5Y=;
        b=k0Nv+/2oNdQibxLiS0FD1/Y4ahMjTquP9jM+wpHzZ18dWvl36lxKlMAcZQG7FjivUF
         YvnSnb1Z4V5UPXeqpfOHPS+VnTQ7QkYHAOX6aLF/+E3Oy/GBTbqmKc0nYaeXCF9nhRm1
         ADGlXBN5BGv+V2q9DJtCSH/GkBoJa105xR2+QzGTDCnt+RL5ka2RW2/r13TImpDkXgf7
         0dF+yxSbPRC9uFq/c6Wt//SVKKpXqKmdwoN2Y5s7rAexzOLf0h8DQTCcdZ4EiiDqAyuY
         NaKuFXbzP7raxlOh5r0pueHaOtYfkgjVhYdZpYaAhpz1WRZw5wQcqcXEsxJThzlZKTDZ
         SLeQ==
X-Gm-Message-State: APjAAAVIP3g74RMStc2NSdniKjv89zGKu/GJ7oclouFRLdCrafEFwsy2
	t3oARemfqDBIrIqZKjWAN+pAp8J7sh94tIFaDYTNJ9P4fpVwZqYmbH3Dziz4sETQYxf1syfY1Jy
	bG/aXr8IweFipTfu/cgGh/0ODUfJCHU4VHeyf5m7H0UA4dO2Gx3zsGvWsdUdMnIbKCw==
X-Received: by 2002:a50:a3b5:: with SMTP id s50mr4285365edb.149.1559218858921;
        Thu, 30 May 2019 05:20:58 -0700 (PDT)
X-Received: by 2002:a50:a3b5:: with SMTP id s50mr4285256edb.149.1559218857938;
        Thu, 30 May 2019 05:20:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559218857; cv=none;
        d=google.com; s=arc-20160816;
        b=s3JG6tybpC8WKgua67//EMZNkkWL+kWUec+8ePoUXw6rSfq2tFp3aVGL5htkmWS59e
         sEL9lDl7jOsyMfRXkk48N9CkCdlE4LUt6Hbkv8r5O1ThvP6b5/1Q+Ve/h05n39xT9n9R
         w8QxIc+p583HuOOmimaMkKVHq8CdDuyGuZmlPv1LLbeIcbT9nP46rj8cEPF9DHsVfLin
         Am3xLwC4T6vjBcs61xhesRGyUQ0FtBDat9SGp2k0q4Gets+rwt3pLFQE5PSFfveLWIal
         7feqUql53pasmrVY1Vvs1Vd6wVzfM+1sKaeYesMNjrun8FMYbL9knH9RlVCjaxZZtaJR
         YGiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=YT3ORHa/ZvJBb9khTyipcwzY8aPEUTPQ5f0pg4jxr5Y=;
        b=TtCXbyAVpNFgCwDnRa1kFyLf71HdF8TidhSs4otwFqoe/S/usujYP18PlJPhPRQMRf
         /kRUgp1q9tujrMFoTX7d8fWdVXRUU4FDisnCDbCOi8npYC0BANiNNNBMY61Y8RWUDuBp
         j0jc70wJPTBwd/EX39PBwtyqzBr/1qjxQor7512J73FzVJaqpe4GkkXQ4nEyM8UBxWmn
         obEBcKzUi2Acc6BKmMNaPj6yXcx0lLcr3Cj7Pb6/aEe/pHT1TKqRfOcNCtSPicclII1f
         XkT//NS0Sci9wC1fyT+BL/dTcqklddcpfFPmTp7SkaQuJxadnmsO9J7QgvXjbP/ki4zg
         E+1w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=Z2k6P15B;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b1sor780096ejq.50.2019.05.30.05.20.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 05:20:57 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=Z2k6P15B;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=YT3ORHa/ZvJBb9khTyipcwzY8aPEUTPQ5f0pg4jxr5Y=;
        b=Z2k6P15BL06hicotC2dSnEhV4GaouaYG/VP+GJ3fGnAhF6at7jpkvpP/YG0JsS3EXO
         /WmsTJLB5yROTZTpRxkMVP5tsNLz1NTj4KHZjtrEY3hwmzJ0k+hnd8h5BPu5s5utlIaY
         4GgG5pQr07iKIMbAzXkcfrvYvubSvkZzB0y/Tgyo+teWVipAtuwqkcQ0mATGh2pId31v
         FlOjjKi7NJhawjq3cI2k0UcyG6Uo1GdWhl0a6KGpV9MNvka+4sAXH206O2kwt8JdXvdP
         xVnDd4ry5jN/dyzJLCyT7PseowF6bzOXZRvj0IjQMxxiKs8NV0ibOIfa+4TYyVwTHni2
         V63w==
X-Google-Smtp-Source: APXvYqz1QMEcICzGq1904VHz2gHy6zj21AwriFZbwIfNLZqfdA6Rb2hqgd+xEtLtBupnaHP/sjhZpw==
X-Received: by 2002:a17:906:63c1:: with SMTP id u1mr3160741ejk.173.1559218857620;
        Thu, 30 May 2019 05:20:57 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id d11sm682334eda.45.2019.05.30.05.20.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 05:20:56 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 975811041ED; Thu, 30 May 2019 15:20:55 +0300 (+03)
Date: Thu, 30 May 2019 15:20:55 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, namit@vmware.com,
	peterz@infradead.org, oleg@redhat.com, rostedt@goodmis.org,
	mhiramat@kernel.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, chad.mynhier@oracle.com,
	mike.kravetz@oracle.com
Subject: Re: [PATCH uprobe, thp 4/4] uprobe: collapse THP pmd after removing
 all uprobes
Message-ID: <20190530122055.xzlbo3wfpqtmo2fw@box>
References: <20190529212049.2413886-1-songliubraving@fb.com>
 <20190529212049.2413886-5-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190529212049.2413886-5-songliubraving@fb.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 02:20:49PM -0700, Song Liu wrote:
> After all uprobes are removed from the huge page (with PTE pgtable), it
> is possible to collapse the pmd and benefit from THP again. This patch
> does the collapse.

I don't think it's right way to go. We should deferred it to khugepaged.
We need to teach khugepaged to deal with PTE-mapped compound page.
And uprobe should only kick khugepaged for a VMA. Maybe synchronously.

-- 
 Kirill A. Shutemov

