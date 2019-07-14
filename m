Return-Path: <SRS0=QXz1=VL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1519C742D2
	for <linux-mm@archiver.kernel.org>; Sun, 14 Jul 2019 18:16:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73A4520644
	for <linux-mm@archiver.kernel.org>; Sun, 14 Jul 2019 18:16:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="EzYn0T6m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73A4520644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD1766B0003; Sun, 14 Jul 2019 14:16:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C82E26B0006; Sun, 14 Jul 2019 14:16:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B72256B0007; Sun, 14 Jul 2019 14:16:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7ECC66B0003
	for <linux-mm@kvack.org>; Sun, 14 Jul 2019 14:16:54 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 21so9057539pfu.9
        for <linux-mm@kvack.org>; Sun, 14 Jul 2019 11:16:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=zu9VDO3r7C4z6bPiJPIw5Tkj2wZpny80iXDdtymKYFo=;
        b=Gc1zzvCdi90v89IIAOk9DR1Ylsm0q02+tEhAfO1oQjAZerO0LcKZhuFyxyS6NtylqG
         9hZ/mbLqNp5WlozpLE2Gdk9LqA8+8hTr3HQd1OjpFL1hR2LAfytizGbRSwUksLEEGpXA
         iMmE9DoKGPvldzvD9FQTOplZ1Z2mmMebUJ/Fis6QBxA7PT3UA2ycoV5ftRgUg7JSJXQ8
         mTJDdw3LbAygS5CTfCnU1HfrtsIImmRjbn9Nttcn5Dy9h59cRNZd7hpfmFTuCZRS292N
         eWnAPO/AYq+d6Y3xi7nY8s4ICH7pqzKx5lMnG3ZVjeYoXya+I0rMW/EEELD/Finunplr
         KXtg==
X-Gm-Message-State: APjAAAXWSxnBoaL02zQN+ACyxACwR54WDnYnskfIKwoocBsvE9WpTdFJ
	SgjtS+PsAWRTTItRbQoPWd45IMvJlUXXEL2CBkq/fQLnafK5ZoWkmasUj2jGpA5vyPscrP3Imm2
	7kd3ZBxXZXvlxMNKn5VT91mjrujWwARXcLkxmNZQ3/JpOP6R6EHpsxI+QaBQjv8bwDA==
X-Received: by 2002:a63:1046:: with SMTP id 6mr23420934pgq.111.1563128213953;
        Sun, 14 Jul 2019 11:16:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJzfEAJkxLmyoLgYOKQ+9uuoPnAeRZ62DyyXItl/1p0nWfLiPgtAWyOYBLdeZLKNToI7+C
X-Received: by 2002:a63:1046:: with SMTP id 6mr23420878pgq.111.1563128213131;
        Sun, 14 Jul 2019 11:16:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563128213; cv=none;
        d=google.com; s=arc-20160816;
        b=jlFx8DTtK7TMqRDT94g9BVj0GJbn9HzBetCAz5SqdW1rjfyslCXvR9aZze4Coo/IL0
         gV0y4xzQ/uYw9Kx3raky8OrWdMRhAFOLZ1hLJ03w/EO+XrdmbCL6XVt6bONm688/27vz
         kgCTw8DnmBqK0kQnDHHKuPq6gLE94PICXw6vCocLsiybc0fRSLRi09ZvGDqvWbxpDgUT
         TCTNtAOfDL413agbmCS9TyQYx5SaWLUCPydYdQDb4KRxQ7yg1PSv90Wb7gzQNz7Ecg7t
         hcsPzzScAqOk1SDka4LcQUORCB6td/mLdQQnUuKL9PCB7ITxQptFS6mntLszUXCYygMI
         EdUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=zu9VDO3r7C4z6bPiJPIw5Tkj2wZpny80iXDdtymKYFo=;
        b=baKrhMSIHU/a2tg+ts6ERqluO/YB0GR9WNWjtvI9IwbSz+HeLHEztaClV1rGJWttdT
         rQ3dQIyUvWKOsMuLE5IdHpCiuHKGfiGOw7mnFfCj+oyIUpoTeLVkMnC+nKW+BDcz/Og8
         Ba2tBJ8P7ILEBjG/c0E5fVRo2O/zDvXWBdytRmQ/EU7t1gRO9y350EBd6gaG8THNOHts
         EamY1Ud4vrFu9IAgpxAmgh2j2CMQ5uVmkZOxkbErJlCtockTkQL2IenUXtOX7Eb82vnW
         VLQMGVkewABNzIAiLzPtyb0JPBWUlnCOp/l7K7Oz0k1mS3H8JcUbGKEk3uEonYGoEE9z
         qMWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=EzYn0T6m;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m9si13385680pgq.373.2019.07.14.11.16.52
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 14 Jul 2019 11:16:52 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=EzYn0T6m;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=zu9VDO3r7C4z6bPiJPIw5Tkj2wZpny80iXDdtymKYFo=; b=EzYn0T6mC7FKpTJ8RU1irxwHC
	abpmpCrn+ITOcYgj8BJxZSu6aQ8Ii0YPXkA/exU0YQAy7O0m7+zOGJ3xNtG1HVipow4mEY+2R1QFW
	yUWv1Dom4OKQzrTOt/MbgsA7dNej/caTkqZhPY4jTEfuejInIA0Otu3kOtE0Y3OFmGhYzyRNA53ot
	8i1Xw/ye+rilRjaF2MiA8RFIjxQIlV1yRtosHFLPp461r/jWR4weAEdfgWYgXPKwsg7h9oaNby5Uw
	Fhn/WXJUh22ci0+2oOYbAzeIHC8bxLEX5nMuy4O4wttLhW0+1HBbETWT8w+KVWUyajs2GLcky3C/l
	obC02yThg==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=[192.168.1.17])
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hmj3K-000704-J9; Sun, 14 Jul 2019 18:16:50 +0000
Subject: Re: [PATCH, RFC 57/62] x86/mktme: Overview of Multi-Key Total Memory
 Encryption
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>,
 Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski
 <luto@amacapital.net>, David Howells <dhowells@redhat.com>
Cc: Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@intel.com>,
 Kai Huang <kai.huang@linux.intel.com>,
 Jacob Pan <jacob.jun.pan@linux.intel.com>,
 Alison Schofield <alison.schofield@intel.com>, linux-mm@kvack.org,
 kvm@vger.kernel.org, keyrings@vger.kernel.org, linux-kernel@vger.kernel.org
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-58-kirill.shutemov@linux.intel.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <a2d2ac19-1dfe-6f85-df83-d72de4d5fcbf@infradead.org>
Date: Sun, 14 Jul 2019 11:16:49 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190508144422.13171-58-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/8/19 7:44 AM, Kirill A. Shutemov wrote:
> From: Alison Schofield <alison.schofield@intel.com>
> 
> Provide an overview of MKTME on Intel Platforms.
> 
> Signed-off-by: Alison Schofield <alison.schofield@intel.com>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  Documentation/x86/mktme/index.rst          |  8 +++
>  Documentation/x86/mktme/mktme_overview.rst | 57 ++++++++++++++++++++++
>  2 files changed, 65 insertions(+)
>  create mode 100644 Documentation/x86/mktme/index.rst
>  create mode 100644 Documentation/x86/mktme/mktme_overview.rst


> diff --git a/Documentation/x86/mktme/mktme_overview.rst b/Documentation/x86/mktme/mktme_overview.rst
> new file mode 100644
> index 000000000000..59c023965554
> --- /dev/null
> +++ b/Documentation/x86/mktme/mktme_overview.rst
> @@ -0,0 +1,57 @@
> +Overview
> +=========
...
> +--
> +1. https://software.intel.com/sites/default/files/managed/a5/16/Multi-Key-Total-Memory-Encryption-Spec.pdf
> +2. The MKTME architecture supports up to 16 bits of KeyIDs, so a
> +   maximum of 65535 keys on top of the “TME key” at KeyID-0.  The
> +   first implementation is expected to support 5 bits, making 63

Hi,
How do 5 bits make 63 keys available?

> +   keys available to applications.  However, this is not guaranteed.
> +   The number of available keys could be reduced if, for instance,
> +   additional physical address space is desired over additional
> +   KeyIDs.


thanks.
-- 
~Randy

