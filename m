Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79759C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 03:19:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3109C21871
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 03:19:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="j0SL2/VJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3109C21871
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C075D6B0007; Thu, 28 Mar 2019 23:19:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB6416B0008; Thu, 28 Mar 2019 23:19:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA4226B000C; Thu, 28 Mar 2019 23:19:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6FD886B0007
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 23:19:00 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j18so149581pfi.20
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 20:19:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=XyQmYDEQuL9iJ6VmFhZOtkvhrL8OV01Yw/rDjyKyWDI=;
        b=g1dmJDu+5jATnMlv8xgCvOTrSPDzDZpzROaq6nMf0Asd4h+4ZQn9aglUQrgGdMpWVn
         H4FNLUCl8cF0mc27bPw2uTi6DC8Pm0+F2AcPnYe7CXXsuyyTVIYz6z5vw/euZ253YptQ
         m1tk/0veSKydev2gITjP3z+KfTeQQ5zsV8W7AEgVhKIPAClvM1LlTzgW81f2NyXj+QaA
         kik6vk8UOJJn5FPF7gvcBiIv0oEUsyMux2MFdIutYvMP2m0H/hZd9p11pSMtpfXW9h4X
         SZyPSJ0UhWZ2QpiWJRoI+Q/7MaXvK4J7xcDZ5B4piNJ8JvXQrZgSoUqUFJVeoV6On06a
         wfUA==
X-Gm-Message-State: APjAAAVWVvseMgjkRkW56C8jHSUaUUsQPLrkgZBOV7bo+f1sJv0nIuXv
	8E6/7GUyj9ridqIxRHxu5MKgyaKkqUCSqSmYtjKZwR5ycBz1az97nUEgTEetPqc1tBaX+PAFEvQ
	3TEJ8xHfjnnocy+VXeH8j6XPD67E34QlueU5VSr7R/uSwTBFjLZTVnxmytl56A8Gw1w==
X-Received: by 2002:a62:6504:: with SMTP id z4mr10352289pfb.202.1553829539987;
        Thu, 28 Mar 2019 20:18:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqziN2eNzpUDluJ0HHhVN367wgI5nAnOaSSpKTLOn4x5MkkRzS+bX+oTS9zusqnQD2dXZ5C8
X-Received: by 2002:a62:6504:: with SMTP id z4mr10352245pfb.202.1553829539089;
        Thu, 28 Mar 2019 20:18:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553829539; cv=none;
        d=google.com; s=arc-20160816;
        b=aZszl3jVaO31MkCs59yb+1FtvdsWUtWUR5Hnl1ZhpWzEOkO9dlYzqQLtIn09KNICtm
         mxkxQJIThmrl+VuGHVKwZkzhgmPRkpjjauJNNHLibQK88WiZvo4zQ2zFNVowbsqLPX+J
         +XWIss0Ltp7FQvWYlE2jww7ZPcpOvbpOj3CKi82jOPpGydzrEYR83iH5Z1OiUQmgegTQ
         CSXgMSYqKuvBoLD1H4LCQZN7tnnu9Ok40bgjPcqMw6pdvc2RYblGhO4LWFnjdu/cq33d
         E0dZ7khSE9Sw2WPix+DBM2y2tqQojiv+YezpvXbzgmdfz5uCBxpT91Xg9TYSN1fFLUXz
         PutQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject
         :dkim-signature;
        bh=XyQmYDEQuL9iJ6VmFhZOtkvhrL8OV01Yw/rDjyKyWDI=;
        b=1Fhi7b+ISXC6dWpIM9gEGVfiUmFad1kjTifDumijtw/JMV5qKwhc3s6nHMUpqdDj6E
         WFfklKaANeKjPitykuEoWhbjm/XVj/jpsPsHj6w4en5HUvD9A6baNbb6GUnhzSxarHB2
         k9F86MJA5CenJd1OrqG2NDlEiTmlz3utiPPU9Kwr9dY8U75XQ5ryp9iEgBpmL7uIwJ0m
         pOEii9iEKzDw4stY40gjTtWnZLqe63b3QC+W9TqXEhVNRG7cnzNNYFdjSnfkX3WOtTqj
         cvresP2u0VoYA0nwe/OvEx0hNKbFaa+HoUCmAOnbrFUbyd/uUD7NhpJwsOA7lWOFHz4I
         vL/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="j0SL2/VJ";
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y3si862788plt.68.2019.03.28.20.18.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Mar 2019 20:18:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="j0SL2/VJ";
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:To:
	Subject:Sender:Reply-To:Cc:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=XyQmYDEQuL9iJ6VmFhZOtkvhrL8OV01Yw/rDjyKyWDI=; b=j0SL2/VJi8eLJc/62YpcPciR5
	fTGZznan0CCvT9h5Z+MqxvEf9rOnWeSMyHtGNvsyPd7g2zkR0SgdGlV0GjcpyTTRozGgKkyu777ZN
	+Ls2bWDzU8TOjwlRp7F9CfMNXNYzBDkIXObHjHX42LecXlT2Go6gL/0vAB/RWaxLo68Kpp3CQmTsm
	GTwIIeSHxusU76jW+zToL2RNwzfqsCMzBBNirrgGoDHl1bfNlWuZvqu8EtuacFLsPKW4v/dI49L9s
	n/oA8iF2LwF4ltQo9YS6dofMaE+unhhkDObIMYArhansr0y9D68tz9nc/FvtsyNfmvcUSdcgIEGYI
	O08903jww==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h9i2d-0001rU-Bz; Fri, 29 Mar 2019 03:18:51 +0000
Subject: Re: mmotm 2019-03-28-15-50 uploaded (gcov)
To: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz,
 sfr@canb.auug.org.au, linux-next@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org,
 Greg Hackmann <ghackmann@android.com>
References: <20190328225107.ULwYw%akpm@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <f4705506-676e-d331-2a96-5f6f5b00f604@infradead.org>
Date: Thu, 28 Mar 2019 20:18:49 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190328225107.ULwYw%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/28/19 3:51 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2019-03-28-15-50 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.



when # CONFIG_MODULES is not set:

  CC      kernel/gcov/gcc_4_7.o
../kernel/gcov/gcc_4_7.c: In function ‘gcov_info_within_module’:
../kernel/gcov/gcc_4_7.c:162:2: error: implicit declaration of function ‘within_module’ [-Werror=implicit-function-declaration]
  return within_module((unsigned long)info, mod);
  ^


-- 
~Randy

