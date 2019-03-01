Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81680C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 20:40:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24619204EC
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 20:40:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=rath.org header.i=@rath.org header.b="g94nagG6";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="1eM0302J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24619204EC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=rath.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1F748E0003; Fri,  1 Mar 2019 15:40:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA7698E0001; Fri,  1 Mar 2019 15:40:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8FAA98E0003; Fri,  1 Mar 2019 15:40:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5CBF78E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 15:40:42 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id a11so19698582qkk.10
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 12:40:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :references:date:in-reply-to:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=gaZtj5W8VUXhVGMnCQf2AvbtnTkW/jB95uYULjvMR+I=;
        b=qoY5VKxwOnR7p0Q6xFAhTH/uaZkkBZ75spuWSWsHkl2VosPJm81jaIrBqGcZ9XKBOw
         w8xFTIzHZ306X/CqMcWgUiLCSeo7FC8+4aNpXnMHCeISd5ckyMo6H4rAthj/nNnvF+t6
         FxvaSDoZM3GKEjfy6wvsrj2bKAiGTpFHeeiMvDkqk3bTN4DpJ1V09gpg349fluJYVQF/
         GlLHzUpY1U/4S/rcIYRox+C2p3MFxZV57YIpwPOPIQTeJCdbHWLSGdxE9QOBvz5qyVe/
         P2bg/XwFfu7w6Bbv7EgDm9UvTVPOf0akW+JW1WPTXmV0ZZeu5o1mTnOehrcCJ7bU3NaP
         iN4w==
X-Gm-Message-State: APjAAAV0HvQmwnJocnarbkCqRtpSpfi0r6YcxO7G/eJzAVW4bPnQqVL7
	fmjbeXVcx2NZWgaeFPCyOGw1CuObqNg47Qt5mybJy4v1SPNXcAlKVhDQbiQo4HXcDok6fiHgwXx
	xOhVP+hPL96Olezoy7wX5NTTUSBZMks0NAtEDqbtVPhmMUrsyJC10WcVAfg8qb0neCw==
X-Received: by 2002:a37:e10c:: with SMTP id c12mr5296747qkm.315.1551472842097;
        Fri, 01 Mar 2019 12:40:42 -0800 (PST)
X-Google-Smtp-Source: APXvYqzKeLF0uVt2BYHIL3GFKU3ts2u28ZjUrlJzFUTkQsrieBUN4WkRc4KK3CFNkmaFY7gnKvgQ
X-Received: by 2002:a37:e10c:: with SMTP id c12mr5296493qkm.315.1551472836453;
        Fri, 01 Mar 2019 12:40:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551472836; cv=none;
        d=google.com; s=arc-20160816;
        b=Izz54NP5d+QqvBkEuD5Wqf8dw6s5bEo7txhKnsW8X9n0GDfI7//o5JTUsxev8FEban
         ZA5RcJ/F0TC2jKBaUmCN/vxrseLIkA8BSTwzFmEmmdMKe1R91eHFODNazMAOq90RMGmD
         Xjky1s+W5fvrPzrapcSxNm2RXKCStDEy8WsPACQVKXpBml8YzWxxcT2deUX3lZwikGxs
         NT1T9dJcEhDVAYmndBmnMqJdY7dXtPABA/rkbh44070CThVyMYXB0jnI3qnv7mhgYwFT
         Hp3bo/G9XfeO6thzRE+9qkf0vFgW1aDXRBKRFyIpUiOHxl6/7/uC7C1qxCAnot3jNmNe
         U53A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id
         :in-reply-to:date:references:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=gaZtj5W8VUXhVGMnCQf2AvbtnTkW/jB95uYULjvMR+I=;
        b=iUgJjYOzNwGPzgwbylXQ22uwPnYdZ8KJr+8TnWFEzkdWyVy08LJuGQBbZajM3oHqC8
         DJ0ju2if6goMIlQwQZmOTexQ4MdL7Q4Oy8kcNEZ8Ugn/EI/6qNe3l0gn7RZjojarEawc
         PQrNfg9UtF4M6IzloeYKVUv6RqAkM6g6bZTkUV7pB5ICqEkAaFjnWxirn3QkEj3PvZqS
         Qk7LKuFOO0PwuJyDLPCYdUVjlmTKE2wnni6ZojyJ9apgdm3tYrkmNutQV6ZeBqesG2ff
         0qVZ006KlNzEzsdrhvhFPsjIKs7Ocz2MJOY+xZWXrzKIGJ841bwTr3H80CfzO6OzSvwq
         gggA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@rath.org header.s=fm1 header.b=g94nagG6;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=1eM0302J;
       spf=pass (google.com: domain of nikolaus@rath.org designates 66.111.4.26 as permitted sender) smtp.mailfrom=Nikolaus@rath.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id k14si5250311qkj.20.2019.03.01.12.40.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 12:40:36 -0800 (PST)
Received-SPF: pass (google.com: domain of nikolaus@rath.org designates 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@rath.org header.s=fm1 header.b=g94nagG6;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=1eM0302J;
       spf=pass (google.com: domain of nikolaus@rath.org designates 66.111.4.26 as permitted sender) smtp.mailfrom=Nikolaus@rath.org
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 9AC2621F2F;
	Fri,  1 Mar 2019 15:40:35 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute1.internal (MEProxy); Fri, 01 Mar 2019 15:40:35 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=rath.org; h=from
	:to:cc:subject:references:date:in-reply-to:message-id
	:mime-version:content-type:content-transfer-encoding; s=fm1; bh=
	gaZtj5W8VUXhVGMnCQf2AvbtnTkW/jB95uYULjvMR+I=; b=g94nagG6Z6UQ4E9V
	UvKyn4Q9qvk7eZkj9SG+fNweP8uMIkOPphNrgb1dmiUwb1L8mWi1rm9fg2JCUgyn
	sWI5wMyha6DLN/AYiiiHTeCvHLSXeoqSN2T99zT8JX30iXGfm2nLRHMse4bIJvXa
	FtimR1BJEMuBxNxs58F0z5fAtjhXdsjtuTJ3RSXfG4skNIW9TH7nrrm07rqgf9p5
	GcMNM/ahicSXpOYb3x+dDtvj2L9MSi+pLSM08eEbtddpgIsgRtMR2C0lhpOaVmJL
	GTN8grXaZ2hkJmRmNJOOLNEml7giyzws+n+G3ac1/EYjlUK7RzgaTCKwoIP4T8z3
	1oWNLg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:content-type
	:date:from:in-reply-to:message-id:mime-version:references
	:subject:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender
	:x-sasl-enc; s=fm2; bh=gaZtj5W8VUXhVGMnCQf2AvbtnTkW/jB95uYULjvMR
	+I=; b=1eM0302JsfRPfNYZigFGlf4pv3B1aGl6WLPXoiSC+RB77eG6ca/Xc7GNl
	7LPrYb+2rmzJBK6z6GvFUVAcrlPqnVsRDsZNW7pbLt54e4iOfz76myAyQ0Gmx7h8
	HC4dFAw9q4M6O/8/rQpH1JDTawmrsvC0R38ypTt48MZ4ZG6upyHAr9UHVnkWG4WV
	QwgzDloE0R4o7TN+QDtjbQmBvfb8uWdIUfarGnGdZNRkn0CQXcBfcv6PFi+D8ejQ
	GXW5U1JLpadxGyZUrzhkkKyB02JMBlX5X9m3X++p5kJvxHysWwjUZVLV7+msH+lv
	7Zayd55UV9LdFhmoD1sQZjacDXrgg==
X-ME-Sender: <xms:wph5XKb-5w3U8-KixsgMa4ZOlTy_d3vC_qENzU0oRXNodWPkGPZpQw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrvdehgddugedtucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    cujfgurhephffvufhfffgjkfgfgggtgfesthhqtddttderjeenucfhrhhomheppfhikhho
    lhgruhhsucftrghthhcuoefpihhkohhlrghushesrhgrthhhrdhorhhgqeenucffohhmrg
    hinhepuhgsuhhnthhurdgtohhmnecukfhppedukeehrdefrdelgedrudelgeenucfrrghr
    rghmpehmrghilhhfrhhomheppfhikhholhgruhhssehrrghthhdrohhrghenucevlhhush
    htvghrufhiiigvpedt
X-ME-Proxy: <xmx:wph5XFHAXT1e5bW7qKjVVqGSR6Ywi10cPvkmKX2B2FVId8kmP4c4gA>
    <xmx:wph5XKw-_imitfq3MDsKeU5C7DX8VJQ82S1tBY24UlPaPDP4Grj3gA>
    <xmx:wph5XOB58Rbd6IS5yeTYr-OLcA3b0oETitw_4Ykgon31E7On0MTtnQ>
    <xmx:w5h5XHyTDbixJdjRkaFK7iPQvYXjOZrA0xaC6S9uvm460X2lMc_yoQ>
Received: from ebox.rath.org (ebox.rath.org [185.3.94.194])
	by mail.messagingengine.com (Postfix) with ESMTPA id 519E1E4309;
	Fri,  1 Mar 2019 15:40:34 -0500 (EST)
Received: from vostro.rath.org (vostro [192.168.12.4])
	by ebox.rath.org (Postfix) with ESMTPS id D917483;
	Fri,  1 Mar 2019 20:40:32 +0000 (UTC)
Received: by vostro.rath.org (Postfix, from userid 1000)
	id 8B274E0089; Fri,  1 Mar 2019 20:40:32 +0000 (GMT)
From: Nikolaus Rath <Nikolaus@rath.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-mm@kvack.org
Subject: Re: [fuse-devel] fuse: trying to steal weird page
References: <87o998m0a7.fsf@vostro.rath.org>
	<CAJfpegtQic0v+9G7ODXEzgUPAGOz+3Ay28uxqbafZGMJdqL-zQ@mail.gmail.com>
	<87ef9omb5f.fsf@vostro.rath.org>
	<CAJfpegu_qxcaQToDpSmcW_ncLb_mBX6f75RTEn6zbsihqcg=Rw@mail.gmail.com>
	<87ef9nighv.fsf@thinkpad.rath.org>
	<CAJfpegtiXDgSBWN8MRubpAdJFxy95X21nO_yycCZhpvKLVePRA@mail.gmail.com>
	<87zhs7fbkg.fsf@thinkpad.rath.org> <8736ovcn9q.fsf@vostro.rath.org>
	<CAJfpegvjntcpwDYf3z_3Z1D5Aq=isB3ByP3_QSoG6zx-sxB84w@mail.gmail.com>
	<877ee4vgr4.fsf@vostro.rath.org> <878sy3h7gr.fsf@vostro.rath.org>
	<CAJfpeguCJnGrzCtHREq9d5uV-=g9JBmrX_c===giZB7FxWCcgw@mail.gmail.com>
	<CAJfpegu-QU-A0HORYjcrx3fM5FKGUop0x6k10A526ZV=p0CEuw@mail.gmail.com>
	<87bm2ymgnt.fsf@vostro.rath.org>
	<CAJfpegu+_Qc1LRJgBAU=4jHPkUGPdYnJBxvSvQ6Lx+1_Dj2R=g@mail.gmail.com>
Date: Fri, 01 Mar 2019 20:40:32 +0000
In-Reply-To: <CAJfpegu+_Qc1LRJgBAU=4jHPkUGPdYnJBxvSvQ6Lx+1_Dj2R=g@mail.gmail.com>
	(Miklos Szeredi's message of "Tue, 26 Feb 2019 21:56:48 +0100")
Message-ID: <87woliwcov.fsf@vostro.rath.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/25.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Feb 26 2019, Miklos Szeredi <miklos@szeredi.hu> wrote:
> On Tue, Feb 26, 2019 at 9:35 PM Nikolaus Rath <Nikolaus@rath.org> wrote:
>>
>> [ Moving fuse-devel and linux-fsdevel to Bcc ]
>>
>> Hello linux-mm people,
>>
>> I am posting this here as advised by Miklos (see below). In short, I
>> have a workload that reliably produces kernel messages of the form:
>>
>> [ 2562.773181] fuse: trying to steal weird page
>> [ 2562.773187] page=3D<something> index=3D<something> flags=3D17ffffc000=
00ad, count=3D1, mapcount=3D0, mapping=3D (null)
>>
>> What are the implications of this message? Is something activelly going
>> wrong (aka do I need to worry about data integrity)?
>
> Fuse is careful and basically just falls back on page copy, so it
> definitely shouldn't affect data integrity.
>
> The more interesting question is: how can page_cache_pipe_buf_steal()
> return a dirty page?  The logic in remove_mapping() should prevent
> that, but something is apparently slipping through...
>
>>
>> Is there something I can do to help debugging (and hopefully fixing)
>> this?
>>
>> This is with kernel 4.18 (from Ubuntu cosmic).
>
> One thought: have you tried reproducing with a recent vanilla
> (non-ubuntu) kernel?

Yes, I can reproduce with e.g. 5.0.0-050000rc8 (from
https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.0-rc8/). However, here
the flag value is different:

[  278.183571] fuse: trying to steal weird page
[  278.183576]   page=3D000000000aab208c index=3D14944 flags=3D17ffffc00000=
97, count=3D1, mapcount=3D0, mapping=3D          (null)

(but still the same across all messages observed with this kernel so
far).


Best,
-Nikolaus


--=20
GPG Fingerprint: ED31 791B 2C5C 1613 AF38 8B8A D113 FCAC 3C4E 599F

             =C2=BBTime flies like an arrow, fruit flies like a Banana.=C2=
=AB

