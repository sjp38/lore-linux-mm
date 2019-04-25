Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 327EBC4321A
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:03:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C4EC206C0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:03:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel-dk.20150623.gappssmtp.com header.i=@kernel-dk.20150623.gappssmtp.com header.b="jxj3YC46"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C4EC206C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 885806B0003; Thu, 25 Apr 2019 16:03:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8333A6B0005; Thu, 25 Apr 2019 16:03:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 721E06B0006; Thu, 25 Apr 2019 16:03:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3B3F66B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 16:03:39 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id q200so590065pfc.21
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 13:03:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=9yZuN8hvykudgvqjrkfkc1ddrIcEZdCLKTPcwNCLMaA=;
        b=kpHgW4UBDsSZwDXHXwM8aiyO3rZSqU5nabuR8HsBVIqtQkX1tG0xgydnvolWB93ZD4
         8CHTk8jiGKNMa9jPk6fJ6OhPF9YstW59pegRQ9n3F9/pgZdS2ZISVM9A6Cpua7nwtNJJ
         szQaahx7Z0gg4mrC8Y1gmC9AszNuFJAbwpI+9vqn+ywAftY3/bn/UfbIaYxJPRRyHv1c
         FbGTVyB4tGvtr5LcIStZz+6HTgSyEkcRVaPGdcpVm1uBGbzMngCKmDL9Qjwu1vqWJkr0
         fw3Qjp4NDMpGBGYc68HFK54dPVBFrRh4iAP3s2V4YxyglDBMw845OctS/iRSQivDZzAz
         +Tjw==
X-Gm-Message-State: APjAAAUe+J+zn94Tn/hrejDHu8sLmUzEBJBydPLZ8lg5n8fZHenj2Sfx
	RMq+TRtuSidMW5aFKBLYyByd6TZx/n37tcxUbnVCL5/zZsXd4Uf0Vz6431OVWItbzTHjqXs1VIi
	sB/vsSzBAo136XsD8rQC+cZ+2ayfyf6B0NWjZ8v8mfdno9YflMU/m4ut8Nh7kAfT+lw==
X-Received: by 2002:a17:902:e305:: with SMTP id cg5mr41366366plb.112.1556222618808;
        Thu, 25 Apr 2019 13:03:38 -0700 (PDT)
X-Received: by 2002:a17:902:e305:: with SMTP id cg5mr41366275plb.112.1556222617814;
        Thu, 25 Apr 2019 13:03:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556222617; cv=none;
        d=google.com; s=arc-20160816;
        b=ud3VcbIKnzqdqPlJgsnX1hLYtv1llySEWEiZtgXMFpxphgLB5ebm0t3CvllDn2BRv1
         yb3zjDSDYavtV7VD+EwGmC9RWR9lb1Y7DTBM/B6T06yXEvAXrANsPslUMHFQL7GoyppJ
         ey3k+/IHiNM0yNvA1lJReQqCTTWn+WwjVzQ+O/hAyawz35wZzrIstXCFT/fIEuN2h4HU
         CYbTywLddgfMvG4ZSpTNpQseJLy7XZWBlXpG/ZmMZirENhXXS8qX0ymYiBilFUnYinQ+
         n9GlCcOcZsxvhYxfwL177/ftuomE6vjZ6xdfcgKr7Q7ApcKiaiUc+13GUKPAQlNQniyw
         aA6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=9yZuN8hvykudgvqjrkfkc1ddrIcEZdCLKTPcwNCLMaA=;
        b=LmXA5o2Tzws6c4DivFW6ujq4CkPzpWE1QjS9MKSb5U0NsOVRmnmuA9V56t9cOmJ6P1
         8zlB2sDy/evoapsqLiZFL3qqMPBN1YoVbm6fPg7DCEPazzkbOphVq7ssO4i8RkRYGgz4
         RL09KmwpZnkdVo6om5XkaXDkO9iiBXT4LYGeG8s874/YEijsxXRH1Z6+TzofPiyU/qJy
         MzLoLvAHxkm0nmCY+3jW8muSxjC/E09StVWGLvVQA0aCLwvIowhG8Dz9Oda2bHaQleHL
         zRq3ORwJeLnP0dOgtbpYKg7Swq5Bh1CZkyqKElWMyTJIjBf7iScilTDZ2wey8lxpXJzT
         h9GQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=jxj3YC46;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.41 as permitted sender) smtp.mailfrom=axboe@kernel.dk
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c20sor3323411pgk.50.2019.04.25.13.03.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 13:03:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of axboe@kernel.dk designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=jxj3YC46;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.41 as permitted sender) smtp.mailfrom=axboe@kernel.dk
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kernel-dk.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=9yZuN8hvykudgvqjrkfkc1ddrIcEZdCLKTPcwNCLMaA=;
        b=jxj3YC4680nC3zgF6cxPeQHLgK/iGzN8Tlj+mFFLrNeeHkYLFqrD5kBQK+MA+ABrpD
         3HdZY+SI810355Q34UQn5l2YkoF2qygTmnfaRRT418kKcjgGRNkalZyvVZnghNKrKk+5
         8YiEcFjel1sFB9TrDXKMonDt4VsQx4nJTS14VV/caPIvx5YvPh6m5JaQKjHXFUtfflKZ
         CkZroAWM8JAi/N5Kg1k21//RnYVPH4vypnIv/cJq/2vVcN7eCsKyB76PjqpVQfzy1Lbr
         VuXMCaokC5PBgIf40n6iBXQjGCWpJwTK3hJ7gl3UmaV4LvMrrEmI6P3aoDHIlBvc7pQs
         rdOg==
X-Google-Smtp-Source: APXvYqzinmBulxOLUVkKOmvGyBuy+TAx1zleDgIu4dJ1S/hJNTGiV/7BAXP7lqbewJBtfWlGuzpvDg==
X-Received: by 2002:a65:5286:: with SMTP id y6mr38424683pgp.79.1556222616888;
        Thu, 25 Apr 2019 13:03:36 -0700 (PDT)
Received: from [192.168.1.121] (66.29.188.166.static.utbb.net. [66.29.188.166])
        by smtp.gmail.com with ESMTPSA id b1sm26204135pgq.15.2019.04.25.13.03.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 13:03:35 -0700 (PDT)
Subject: Re: [LSF/MM] Preliminary agenda ? Anyone ... anyone ? Bueller ?
To: Jerome Glisse <jglisse@redhat.com>, lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
 linux-block@vger.kernel.org, linux-kernel@vger.kernel.org
References: <20190425200012.GA6391@redhat.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <83fda245-849a-70cc-dde0-5c451938ee97@kernel.dk>
Date: Thu, 25 Apr 2019 14:03:34 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190425200012.GA6391@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/25/19 2:00 PM, Jerome Glisse wrote:
> Did i miss preliminary agenda somewhere ? In previous year i think
> there use to be one by now :)

You should have received an email from LF this morning with a subject
of:

LSFMM 2019: 8 Things to Know Before You Arrive!

which also includes a link to the schedule. Here it is:

https://docs.google.com/spreadsheets/d/1Z1pDL-XeUT1ZwMWrBL8T8q3vtSqZpLPgF3Bzu_jejfk

-- 
Jens Axboe

