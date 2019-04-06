Return-Path: <SRS0=nlaJ=SI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FORGED_YAHOO_RCVD,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3D6DC10F06
	for <linux-mm@archiver.kernel.org>; Sat,  6 Apr 2019 06:15:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C0AB2173C
	for <linux-mm@archiver.kernel.org>; Sat,  6 Apr 2019 06:15:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=yahoo.com header.i=@yahoo.com header.b="G/bi6eHA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C0AB2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=yahoo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DBCDF6B026E; Sat,  6 Apr 2019 02:15:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6BD46B0270; Sat,  6 Apr 2019 02:15:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C34376B0271; Sat,  6 Apr 2019 02:15:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8B52A6B026E
	for <linux-mm@kvack.org>; Sat,  6 Apr 2019 02:15:48 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id x5so5696994pll.2
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 23:15:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:reply-to:to:cc
         :message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding;
        bh=BFJWdwxeFmvgdvdlDac5VDeh/vYmhJNFPdmYXnJUdGc=;
        b=eu/CcsV6rkHRr8gSO/a4nUY/wmsKIJYRBHetGCE14skNsah4DHNCjZshD5HcrcPTW+
         Ln5u1wBXK1Allum8sgmbtV+6xxfDiJt9xpf9KwUv1HNc8RBKDXJLZSXVVeBUxZGNJKf9
         meI/we+IYLizn52tZHJsY15U/Hty2BeRVrXZZtwd0KgpEKJRxuZM61KSKYrw0oKrw/Rk
         UMNPI2hFCZJdO0f0cTRr9EZaTfg6AAB9qWMw/YJrjMzopcqLM2cxsBJtgFCXbi+6PIjS
         Y+BxJYM23ey0f+UhBPUH26BeQZ/qugs7pn+C/3twoiCsEi/hjo0syG06UpdDE2XKTCw6
         2y4A==
X-Gm-Message-State: APjAAAXCg+tWV03oN0u8UVHRnBoP0cMOJecL3lYrVCBGb2rStdZ8nC3m
	mQI1R2Lc1XIi2pfJv16PMJfc5giDyLky3//LyTvySeaB6YpT7x7CnsG7kTzc3Qs4+X4CLh1j4cT
	88uy3HTINGLHl6K2MatZXXr3rLWHrmWNXAB93nfRp3XpOO5vP1611XzEgCLzfxR8uUg==
X-Received: by 2002:a63:2c09:: with SMTP id s9mr11382901pgs.411.1554531348093;
        Fri, 05 Apr 2019 23:15:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzSkBwu3O26l+1dhGMtHnv6fA+RzmIT3MZ7piTjt7Ibn8BjNAmjrv7MTyoHNOYiVAy8A5BX
X-Received: by 2002:a63:2c09:: with SMTP id s9mr11382856pgs.411.1554531347326;
        Fri, 05 Apr 2019 23:15:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554531347; cv=none;
        d=google.com; s=arc-20160816;
        b=QrcXT1umY8mQsU3ZChLlg4uKU9DaYNWJHsQ/uQlrsCDOdyv+TACMsgNW6qzDh0Fx8N
         igLpWK0RO8c0dcPfq0cVAMHHMgA1G2uan8IhzG7OUpqws//pbdjaPe2p4cg3IinrME3i
         ZEhS7WmmO3utGMtkjFUzF/qZkQNfZcdW0ZNbKgLQOmy1mjpV7UR9S2OlBj1r9NMM5kOu
         ExZOicLRv4RqmsXkoBZ/84HtF3gPDyl5LAjUeky7vju8El1+vrQKLWld/fY1NCUYo0N/
         QL4DCuLcCGF/fEUwVsJB7faRzAYBG1iabr7G9bt4ZN4pAY9AYOdCHA8VVrUIzpX5vu0U
         bMFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:subject:references
         :in-reply-to:message-id:cc:to:reply-to:from:date:dkim-signature;
        bh=BFJWdwxeFmvgdvdlDac5VDeh/vYmhJNFPdmYXnJUdGc=;
        b=AM0GTajCbiDPGV+fJ6onzaT5MwwPKGp2dOSMbWFflbrqmu6lTQtZRglNHrLFMb9VE3
         OQIdGZVn8+kMDMA+eQj6vlZU8xr6BcukW9oOwKxbMyWhwHkvLuYdKMmVoTP5KmjTttbt
         8kNLBqaSr6dE8EdXV/te+GJS9BBDv0xpkQWNHkxF2jGQppIaxiYUO32MdzlXxdXIo/0e
         r6XxUbXbG+QVUlmG71NyVmwYBGtRhVNMBXfXS814qynDe4x1OtNmVFMW3bjbNQSy5pkG
         u2DsHtbiyhBuRnbjxlYHXYhD0mTpCgMnyy7XLmiYMVXygSw0RabkQzM0OV0NE4Bg4XaI
         CmDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yahoo.com header.s=s2048 header.b="G/bi6eHA";
       spf=pass (google.com: domain of suryawanshipankaj@yahoo.com designates 106.10.241.211 as permitted sender) smtp.mailfrom=suryawanshipankaj@yahoo.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=yahoo.com
Received: from sonic308-21.consmr.mail.sg3.yahoo.com (sonic308-21.consmr.mail.sg3.yahoo.com. [106.10.241.211])
        by mx.google.com with ESMTPS id t69si20738302pfa.7.2019.04.05.23.15.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 23:15:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of suryawanshipankaj@yahoo.com designates 106.10.241.211 as permitted sender) client-ip=106.10.241.211;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yahoo.com header.s=s2048 header.b="G/bi6eHA";
       spf=pass (google.com: domain of suryawanshipankaj@yahoo.com designates 106.10.241.211 as permitted sender) smtp.mailfrom=suryawanshipankaj@yahoo.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=yahoo.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yahoo.com; s=s2048; t=1554531345; bh=BFJWdwxeFmvgdvdlDac5VDeh/vYmhJNFPdmYXnJUdGc=; h=Date:From:Reply-To:To:Cc:In-Reply-To:References:Subject:From:Subject; b=G/bi6eHA1q4GILAKl3kscHU/qhAAadl8CDyCXVCHV4nYqVM/TuPbdzd+gLlfGoxiapeau9PgvRT+hOElVvqjA25xsnwWdBI6z4d5RY9UML81AGynuGGCEadKb0BdXGgAKmXz1xq/kEcHLQXAjjCZY4cctEd6poK5ZUXcGssHS43WSTNm4ERjAR1Q96D1mwZ+Bn0wM33mp0m89GdqUGtCreCI3kj/7iisVqaYdlxj117VbQJxE/yyOdJaSKdLB3qWEETS2WZAl38gFjQ44FymOgy1qlo/pzZjC/Cm+GjSwoi9WBPGEHcIFrm17EA6KKiiT0AzYk4vx9tolaKT5HepxQ==
X-YMail-OSG: YS8M6PMVM1kUGENqFeq55b0QSQTuukR8ig4hRptCRW1ii6dACBnilc2.m45.mGt
 Ps8RspU9wK1c6R7SOUqaTfLEZQs6HBB1VeeWPq5EzuMo4h3tRSMkbYrNer8fWMDWJs32dV.dImDp
 3boaOZghdRI7numlmAeUTXqNOpzG8eENt1N_2RqBvwVyOlqMl.0BvviKNv9sC47adwAe0mjX.nsq
 FTg2AFOMHhfrRTN0_BY3G53tpsqTanIsSznKZC8GSqEW1o4_D1y8Wf_d2nNpjPRN2fb5dhQmPdoA
 A4eGeFJz9Ki3w2Jcmzl61DNpLl_o9IgH5vQxNcg_nnlaBFWlZNTojmKZwVkTmXgZ5IBj527lWNIB
 HnqJdkdgHXAn5sWGQOF_snFWgPCnD44qMCC6Q727HFJGIKR4_60qhdvLThF6Pv6_MB65dLUzCVM6
 OEFjmPPJMx.SzQOZ9ZsE8yqW9eAnPe2cEuH_23Hpevj8HpG3_AZoVC9PU_XQjfOqgu7XqsOf8tL5
 1bxD26iCl4COHRJRvaWFinfJIwbZfZ3yTjM95MIgEJugN7oGqeAkg5IJig3vPK7q03E29cL0SfpG
 sPOGIjfxFI13T0hxhoSDLt5PnZsDDpI_eAYwAhJkW7fksB9cKAsxel9hMBaPOJVmaa5b90ERbp0A
 L41Lc3qRabLFqQ.2YWr9fMQJJCOORI8PblEBz3TsFrF6plshW3HANTxBa_NyShzzmHbLjXudtLrr
 3lar5SrVmZPlIESGSV21yxGyj0iay5aE329wTCXrRo21ylPkW2eP4oLawlrdn8oMnPgH4lfcnMAz
 1tuK0Eejfdoh4VaSlvx.ITovkNCVthox66GwXCdRWr_laP8RtpEqa1FhERFCY4DKsnMuaMX1Mbdc
 7FZX0zLWsVy2aZsw9ea1336nxq1WdRVamoC07fHZCMfhhPe9bTlihzMCDrBEOWTJ3mKR97oQz16y
 nycYsWg67Y317nNybMOIUu8ABexsuJi9cGpoUHN5OLpn4X9aYBxj19Iukc_ysqYa_UPu.b7nv2FN
 pND3yWEVQ23KZa8tJn6eipH7WlnKS5VyQOQPh8r7G1S_3Whc6y61pfzsjXPTABO4ljw7ZjmyW33n
 tyQ--
Received: from sonic.gate.mail.ne1.yahoo.com by sonic308.consmr.mail.sg3.yahoo.com with HTTP; Sat, 6 Apr 2019 06:15:45 +0000
Date: Sat, 6 Apr 2019 06:15:41 +0000 (UTC)
From: Pankaj Suryawanshi <suryawanshipankaj@yahoo.com>
Reply-To: Pankaj Suryawanshi <suryawanshipankaj@yahoo.com>
To: =?UTF-8?Q?Valdis_Kl=C4=93tnieks?= <valdis.kletnieks@vt.edu>
Cc: LKML <linux-kernel@vger.kernel.org>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"kernelnewbies@kernelnewbies.org" <kernelnewbies@kernelnewbies.org>
Message-ID: <1002302887.779027.1554531341350@mail.yahoo.com>
In-Reply-To: <6977.1554499657@turing-police>
References: <1536252828.16026118.1554461687939.ref@mail.yahoo.com> <1536252828.16026118.1554461687939@mail.yahoo.com> <6977.1554499657@turing-police>
Subject: Re: How to calculate page address to PFN in user space.
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Mailer: WebService/1.1.13212 YahooMailNeo Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.86 Safari/537.36
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>





On Saturday, 6 April 2019 2:57 AM, Valdis Kl=C4=93tnieks <valdis.kletnieks@=
vt.edu> wrote:



On Fri, 05 Apr 2019 10:54:47 -0000, Pankaj Suryawanshi said:


> I have PFN of all processes in user space, how to calculate page address =
to PFN.

*All* user processes?  That's going to be a lot of PFN's.  What problem are=
 you trying

to solve here?

I am trying to solve problem with cma allocation failure, and try to find p=
rocess who pinned the pages from cma reserved area.

When cma allocation failed it dumped the information and it contains flags =
and page address, before failing i have information/PFN of processes who aq=
uires pages from cma area.=20
Now i want to find exact PFN of the dumped pages who is responsible for all=
ocation failure.

Note: I have got the pfn from /tools/vm/page-types.c in user space and i ha=
ve start pfn of cma reserved area, so i filter the cma area pfn.
(Hint - under what cases does the kernel care about the PFN of *any* user p=
age?)

