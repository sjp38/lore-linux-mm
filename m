Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F1EDC43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 14:41:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6F2A208C3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 14:41:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="JBhYcKNb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6F2A208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4951A8E0002; Fri, 21 Jun 2019 10:41:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4441E8E0001; Fri, 21 Jun 2019 10:41:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E4418E0002; Fri, 21 Jun 2019 10:41:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0D3288E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 10:41:33 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id s25so7683893qkj.18
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 07:41:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=iAefoNx0q/97YiPDebPSTk9gILnOd0FXIWcUIRJLLtA=;
        b=c/MP5vRpox+Pz/dBiDf5MgFcZpITN/fDpGNoqg6ION/lP//2MWFzw2uAUSLNAjFhDe
         dtETw3sny7denWclg9ETAg/iDU3HLzKDXDQ91ybNQrPrJKfQyqjNJmfpN2OG2bafv2gW
         b2ocLHC7ldZmKOel8ZCr9g13ahQ4ACotlVduQOwfHmy48uga/PsG46AuV6MNLw+Nzg/u
         tCDWV9cip0I7Mi86V+qxR9tylhiUIFj7ighFqUN80idvnx/Jn0g8zwVg1sc88V3AtUpW
         eri3geEo2sGrIqgCeNstSQFZ0/GHeGyJwW8Tp8PmvmUGrcyq5BTtbcZg5XElqtt85eny
         7poA==
X-Gm-Message-State: APjAAAVhp7BT+SBFMi4+Cba6lnDr1PcvcO/i4Pe9ZgljuQW/JbEV0EAi
	cDQPYcCTkETW7VTOqJY1IcXVykjMHU5Fp1IYk/eKpaGjHQCYqPYVeHnevz4jlEFTHmD+8+M/L/B
	jmIhHTnySq5kK3c7FrdfHb4ckieXOauBGqAzCQsjZEzgjJMshWwJ+dZ2lCgLdxaFK2Q==
X-Received: by 2002:a05:620a:1425:: with SMTP id k5mr108551806qkj.146.1561128092787;
        Fri, 21 Jun 2019 07:41:32 -0700 (PDT)
X-Received: by 2002:a05:620a:1425:: with SMTP id k5mr108551773qkj.146.1561128092302;
        Fri, 21 Jun 2019 07:41:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561128092; cv=none;
        d=google.com; s=arc-20160816;
        b=GaxPqs2preunR9B9TF7Bo5yOJf5QHOXkeg96BlNM+K81UwDlXzhDcwNGHg/j7KEWP9
         uHAtyunUUGjsNq5zS+/3jvlXh/rdkG5aZCMG99BDbgAt7kyG73A665zNMytkMiclClM4
         oBvjIqxQkL6VLjh7enMH8Yy/gnDCuDqiO0PmftAhvlive81Efa/zn+3/RRFT64Y+3Hjs
         6wKOvkLtOmxSN0NSdqQdpd7ht1pkUNQxUviP1uSiOEK3R42OFSz8L4wUYimh3VNYCheE
         3QPkc6922xcBB2/D0O51cDBIidi+tL/1pJ20mVIO5n0TOMpO2B5yBJAhFzrT/8vpS7Tf
         UJdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=iAefoNx0q/97YiPDebPSTk9gILnOd0FXIWcUIRJLLtA=;
        b=gMKuuHq/zczmDYnIuQbi/T+3I9ZAOFljXMSE4UUF0s1IcrpF6T+Z1yHj/a+OQoGHNt
         SGR0tiDi3RQ2roMaWHrIZ79TdzvNMgRs0gx26Sic69r59yzlawIfhhfCLLyQyM2prBuC
         V4E86PkSAG0mIIiAD+/4+kjrJ1Srx0tIKR6rQhLzD3u3H/C6DYAurtnyLDRYoZ62Q+Ri
         rDI+OnDLzWZbHd5jXv1vpm3AAE+WDV2KlGr7D/zWBXdzf3CzUdw6tSOo9RYtf/J+x0/k
         4l4LlrysGA7VkC7+lU1WAXm2gKgRSsstgWTeqaunT2D305uXo+CUqLlsKI4XfGz8Afh1
         qwSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=JBhYcKNb;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 48sor2461420qvk.63.2019.06.21.07.41.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 07:41:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=JBhYcKNb;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=iAefoNx0q/97YiPDebPSTk9gILnOd0FXIWcUIRJLLtA=;
        b=JBhYcKNbnw5KS/Bw3jUGnXGizAYOGrGCynlCyAlg63WK1n8IqOySZ1+bye3/YiT63n
         v8/sbGh4AD1MHRynheN2Dlq8lFKIq7z1NImXxzvLdoGCc7lemxe5AEO2L8rqLF3E00oD
         oaCz+g/xDkcmsm0KQgBXxPRK1i/pBAcltUXftd0yNlKSLRQGkTTISqj5EmoKiqW1z/7C
         xGMPI7hpBo4aEfjJYbvL1QdYdl0bqL8gAEgqgeQ8mr+Rnu3ZBMhGaV4qz/zk8iv9SFhb
         jZCzIqRVkaT3gufXwch0VFa0geY+UKfMoNAoGmczoezyVySF3//gJOB7bFyrvTarIu6t
         jP6g==
X-Google-Smtp-Source: APXvYqwAiNjv+b7qPtfzYMe/a9zWSjQhOq9v3skvi7StNK2ILH/OsN4mGdlL0jsjEcF4n4D7/7paYA==
X-Received: by 2002:a0c:b12b:: with SMTP id q40mr15375817qvc.0.1561128092068;
        Fri, 21 Jun 2019 07:41:32 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id c55sm1767604qtk.53.2019.06.21.07.41.31
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 21 Jun 2019 07:41:31 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1heKjL-0000un-67; Fri, 21 Jun 2019 11:41:31 -0300
Date: Fri, 21 Jun 2019 11:41:31 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 11/16] mm: consolidate the get_user_pages* implementations
Message-ID: <20190621144131.GQ19891@ziepe.ca>
References: <20190611144102.8848-1-hch@lst.de>
 <20190611144102.8848-12-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190611144102.8848-12-hch@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 04:40:57PM +0200, Christoph Hellwig wrote:
> @@ -2168,7 +2221,7 @@ static void gup_pgd_range(unsigned long addr, unsigned long end,
>   */
>  static bool gup_fast_permitted(unsigned long start, unsigned long end)
>  {
> -	return true;
> +	return IS_ENABLED(CONFIG_HAVE_FAST_GUP) ? true : false;

The ?: is needed with IS_ENABLED?

>  }
>  #endif

Oh, you fixed the util.c this way instead of the headerfile
#ifdef..

I'd suggest to revise this block a tiny bit:

-#ifndef gup_fast_permitted
+#if !IS_ENABLED(CONFIG_HAVE_FAST_GUP) || !defined(gup_fast_permitted)
 /*
  * Check if it's allowed to use __get_user_pages_fast() for the range, or
  * we need to fall back to the slow version:
  */
-bool gup_fast_permitted(unsigned long start, int nr_pages)
+static bool gup_fast_permitted(unsigned long start, int nr_pages)
 {

Just in case some future arch code mismatches the header and kconfig..

Regards,
Jason

