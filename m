Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEA36C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 10:49:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7605F204EC
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 10:49:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=mailbox.org header.i=@mailbox.org header.b="BgXYm5zU";
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=mailbox.org header.i=@mailbox.org header.b="Z0hyfSMJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7605F204EC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mailbox.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA80E6B0005; Thu,  4 Apr 2019 06:49:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E560D6B0006; Thu,  4 Apr 2019 06:49:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF80F6B0007; Thu,  4 Apr 2019 06:49:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6E1616B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 06:49:09 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c40so1171737eda.10
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 03:49:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:mime-version
         :in-reply-to;
        bh=862shIMihyGGcrrzG/5RFJGlHmcu4xvUGWw+3MoGLYU=;
        b=q2COyWnWFfUybKdmESS4mtPA/25HaqcTo3xnINOwjLgBDFyLEMwiinoOQJgeWWWcSy
         p/wcn6wCSiXlqtlA/YVX2i0pmfLwL66YCWo9QKIVQA20jFskeKjq/2Azy2xX212Ob6GJ
         tOhVENenGGavATYHCG1YcJRS2G72qTznCsS0RYBRjt6HkFZAQCXmsVqTU/Y3SC43KOQB
         jd7G1PVWrgbbh1enc83Fr8B8bmFCkS8gXad+UEqB2dJhWKwRPiG6eCdzIOYFUh362rEo
         xmcN8OrdBNIynBv4lJAWDMikyRKgTCB94jXX5471zBRem/6pyFxtiqo1ETqxuigMv4Xc
         qnfg==
X-Gm-Message-State: APjAAAXipaG/2umGBiHHcA7oUW57yQk151zuZKbxtpiOd26ykK10Sif5
	B4ggL5Od5Msy//YAZnbrKr21dIooR/35ziYh6S7EgFGNHnoPw2QsWVN+3SNQsQuagnaQig9E0fG
	L/BWkWmAglLqlrBpazmVC22ma/gTrWxw5X/MuohGiosLSJFLIBTg6XdpFxGzYV17TDg==
X-Received: by 2002:aa7:d819:: with SMTP id v25mr1139147edq.70.1554374948802;
        Thu, 04 Apr 2019 03:49:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyJo+p6lyKYZIzK3zmPbQji1EB663l/aW1Kpjdp2zZCsxJ/BIVVK+yig+8F6BX25WKF/D+8
X-Received: by 2002:aa7:d819:: with SMTP id v25mr1139066edq.70.1554374947278;
        Thu, 04 Apr 2019 03:49:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554374947; cv=none;
        d=google.com; s=arc-20160816;
        b=E5PVTXCAJS+Zn0+dRW3o95iGDcc2PwchN69vdSAmUOIvN3eaBE5HFSXdJN4xWh9ZEJ
         t1+iZvEQ97i1jR8m6y7aIc+aNEe6rKzNkWkJF9sn1v+SM13czl2mpUGcnaLIk0eH/8m7
         M1QYJRDko1XOus2EiNpV4rUiyZMTZ8BJjnVXnraNtv4Uyo1uplXKsQlIr7CAFrYPdDNA
         RwG2C6ytsStxeAA+LBl5rfXnx93wiRHYE86oDwxtaBO3XMsS7xZHNRa4mt8J1Q+cUDKq
         GFdsW9Tno1IzdLuGWLLYM+Xr8j1F6WiPmuI2sX+CCT1OR7vcp11Ps3sTHuOVrliT1bBr
         WxOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:date:message-id:autocrypt:openpgp:from
         :references:cc:to:subject:dkim-signature:dkim-signature;
        bh=862shIMihyGGcrrzG/5RFJGlHmcu4xvUGWw+3MoGLYU=;
        b=fMMDC9qeCHjOGrfj/yjDSdDq9kNIaymce6QI76/6VErWbG21kXSdbV0X5XSGlmaql7
         C1e7exlqZmwCU/69Z3AaM/rsHxtmzSEBoJJm1X7c0qA3TBMlVczAASzvyq34eZUBYOBN
         JqLMW2Mg2ig1heB/d2aeb0KlQxvHrIfztPnNrPLtC9GrEh77h0fiP5aoWpE1VzRtpGom
         gzgq70+YjUi7gi88cw8JI0fjxhEwm6jAeL+M98GOeClu56AJTrXKX7oBJg5+J84gIU45
         ZFgaoT20b6gJeGISJWBzvmF/2hNdMALc8w85f04xUbOFxGBQCjxrqN1eQgfd/cLKfZia
         6qXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@mailbox.org header.s=mail20150812 header.b=BgXYm5zU;
       dkim=pass header.i=@mailbox.org header.s=mail20150812 header.b=Z0hyfSMJ;
       spf=pass (google.com: domain of jrf@mailbox.org designates 80.241.60.212 as permitted sender) smtp.mailfrom=jrf@mailbox.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mailbox.org
Received: from mx1.mailbox.org (mx1.mailbox.org. [80.241.60.212])
        by mx.google.com with ESMTPS id o17si1658636ejn.80.2019.04.04.03.49.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 04 Apr 2019 03:49:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrf@mailbox.org designates 80.241.60.212 as permitted sender) client-ip=80.241.60.212;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@mailbox.org header.s=mail20150812 header.b=BgXYm5zU;
       dkim=pass header.i=@mailbox.org header.s=mail20150812 header.b=Z0hyfSMJ;
       spf=pass (google.com: domain of jrf@mailbox.org designates 80.241.60.212 as permitted sender) smtp.mailfrom=jrf@mailbox.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mailbox.org
Received: from smtp2.mailbox.org (smtp2.mailbox.org [80.241.60.241])
	(using TLSv1.2 with cipher ECDHE-RSA-CHACHA20-POLY1305 (256/256 bits))
	(No client certificate requested)
	by mx1.mailbox.org (Postfix) with ESMTPS id A22234CA15;
	Thu,  4 Apr 2019 12:49:05 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=mailbox.org; h=
	content-type:content-type:in-reply-to:mime-version:date:date
	:message-id:from:from:references:subject:subject:received; s=
	mail20150812; t=1554374932; bh=pomGJm/E1RnUEvWDS+UGcPvmSNoL1K6Xh
	ANtc9GLQt4=; b=BgXYm5zUz+2OFu5ND2XxH5miQS5GB8QFZXEZmPR97SkBmFEQ6
	wCiGCbz72XTYcM5S1jCvZG9+C2ofKbOC9ASwhIYQJHKQL+bIneZLTczSsAaZM2pi
	yLCaD2h74sPTMa6CtoMAHv6PMvwzaHwDCpERGChqt/myvLWWcBjY3+EwXWy+Cy27
	wObIgTpt4oYlKz4cx94uPlSTbGUZEwFRMSUfGq15/7Sbo57wlvsXr2es7bEshJFe
	u3omrle9aXo+GMx1GNNYtKC0GFG7AYiu3mylZbUGKtL2LaSRP32JLgmYe/Kfey0i
	ZwPNzJDz6vw8pVd2WYpt49kZZN8b1KX7WeDLA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=mailbox.org; s=mail20150812;
	t=1554374941; h=from:from:sender:reply-to:subject:subject:date:date:
	 message-id:message-id:to:to:cc:cc:mime-version:mime-version:
	 content-type:content-type:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=862shIMihyGGcrrzG/5RFJGlHmcu4xvUGWw+3MoGLYU=;
	b=Z0hyfSMJ6fDMfCxuvNuOUUHQkwd7CXmU+xdZd9tLKikBCKyTs33MmKolnCB0mFlUU4BFy4
	jukz8+DfirZutJdykkBHbkp+6Olnwk+TVnb9RnAIMhXEZIBSrZXvdBf2HZrFBvGkd/APR0
	Kk5DUu4dmyLIKgqhxL1UkfHBnXRgj+um0elCupham783U/JTMY7s8EH6NCXQkctMjm3u29
	iPZN7vSZGZz8sNGRiAXKviLZWGCWLdsZXFCATJVaXwr9no+X3aaTA7cqJaWcYOMtq5KxXl
	+KV7Bpp/IR0fYRMbfW312cmEUJ9I2ixp5IEgpUjdcYGPzksLNMPxQYQiuuVrcg==
X-Virus-Scanned: amavisd-new at heinlein-support.de
Received: from smtp2.mailbox.org ([80.241.60.241])
	by spamfilter02.heinlein-hosting.de (spamfilter02.heinlein-hosting.de [80.241.56.116]) (amavisd-new, port 10030)
	with ESMTP id 6NAuWHa4to86; Thu,  4 Apr 2019 12:48:52 +0200 (CEST)
Subject: Re: [Bug 75101] New: [bisected] s2disk / hibernate blocks on "Saving
 506031 image data pages () ..."
To: Matheus Fillipe <matheusfillipeag@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>,
 "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
 Johannes Weiner <hannes@cmpxchg.org>, =?UTF-8?Q?Rodolfo_Garc=c3=ada_Pe?=
 =?UTF-8?B?w7FhcyAoa2l4KQ==?= <kix@kix.es>,
 Oliver Winker <oliverml1@oli1170.net>, bugzilla-daemon@bugzilla.kernel.org,
 linux-mm@kvack.org, Maxim Patlasov <mpatlasov@parallels.com>,
 Fengguang Wu <fengguang.wu@intel.com>, Tejun Heo <tj@kernel.org>,
 "Rafael J. Wysocki" <rjw@rjwysocki.net>, killian.de.volder@megasoft.be,
 Atilla Karaca <atillakaraca72@hotmail.com>
References: <20140505233358.GC19914@cmpxchg.org> <5368227D.7060302@intel.com>
 <20140612220200.GA25344@cmpxchg.org> <539A3CD7.6080100@intel.com>
 <20140613045557.GL2878@cmpxchg.org> <539F1B66.2020006@intel.com>
 <20190402162500.def729ec05e6e267bff8a5da@linux-foundation.org>
 <20190403093432.GD8836@quack2.suse.cz>
 <1ea9f923-4756-85b2-6092-6d9e94d576a1@mailbox.org>
 <CAFWuBvcS-8AFZ4KoimMrLPjFXGE8a48QnSqV3_gajJNWYZymGA@mail.gmail.com>
 <56c1efb7-142b-9ae3-7f59-852d739f6632@mailbox.org>
 <CAFWuBvfxS0S6me_pneXmNzKwObSRUOg08_7=YToAoBg53UtPKg@mail.gmail.com>
From: Rainer Fiebig <jrf@mailbox.org>
Openpgp: preference=signencrypt
Autocrypt: addr=jrf@mailbox.org; prefer-encrypt=mutual; keydata=
 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
 SJBEfJI=
Message-ID: <b44b1264-25ff-336c-9db5-59ab2adbddf3@mailbox.org>
Date: Thu, 4 Apr 2019 12:48:52 +0200
MIME-Version: 1.0
In-Reply-To: <CAFWuBvfxS0S6me_pneXmNzKwObSRUOg08_7=YToAoBg53UtPKg@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="5hDTI6kuNPaeZpVR9mGMDtYctWudSR8l3"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--5hDTI6kuNPaeZpVR9mGMDtYctWudSR8l3
Content-Type: multipart/mixed; boundary="4x6JFQYtFRGjXrc3IWkjK6HSONjtqIxak";
 protected-headers="v1"
From: Rainer Fiebig <jrf@mailbox.org>
To: Matheus Fillipe <matheusfillipeag@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>,
 "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
 Johannes Weiner <hannes@cmpxchg.org>, =?UTF-8?Q?Rodolfo_Garc=c3=ada_Pe?=
 =?UTF-8?B?w7FhcyAoa2l4KQ==?= <kix@kix.es>,
 Oliver Winker <oliverml1@oli1170.net>, bugzilla-daemon@bugzilla.kernel.org,
 linux-mm@kvack.org, Maxim Patlasov <mpatlasov@parallels.com>,
 Fengguang Wu <fengguang.wu@intel.com>, Tejun Heo <tj@kernel.org>,
 "Rafael J. Wysocki" <rjw@rjwysocki.net>, killian.de.volder@megasoft.be,
 Atilla Karaca <atillakaraca72@hotmail.com>
Message-ID: <b44b1264-25ff-336c-9db5-59ab2adbddf3@mailbox.org>
Subject: Re: [Bug 75101] New: [bisected] s2disk / hibernate blocks on "Saving
 506031 image data pages () ..."
References: <20140505233358.GC19914@cmpxchg.org> <5368227D.7060302@intel.com>
 <20140612220200.GA25344@cmpxchg.org> <539A3CD7.6080100@intel.com>
 <20140613045557.GL2878@cmpxchg.org> <539F1B66.2020006@intel.com>
 <20190402162500.def729ec05e6e267bff8a5da@linux-foundation.org>
 <20190403093432.GD8836@quack2.suse.cz>
 <1ea9f923-4756-85b2-6092-6d9e94d576a1@mailbox.org>
 <CAFWuBvcS-8AFZ4KoimMrLPjFXGE8a48QnSqV3_gajJNWYZymGA@mail.gmail.com>
 <56c1efb7-142b-9ae3-7f59-852d739f6632@mailbox.org>
 <CAFWuBvfxS0S6me_pneXmNzKwObSRUOg08_7=YToAoBg53UtPKg@mail.gmail.com>
In-Reply-To: <CAFWuBvfxS0S6me_pneXmNzKwObSRUOg08_7=YToAoBg53UtPKg@mail.gmail.com>

--4x6JFQYtFRGjXrc3IWkjK6HSONjtqIxak
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Am 03.04.19 um 22:05 schrieb Matheus Fillipe:
> Okay I found a way to get it working and there was also a huge mistake
> on my last boot-config, the resume was commented :P
> I basically followed this: https://askubuntu.com/a/1064114
> but changed to:
> resume=3D/dev/disk/by-uuid/70d967e6-ad52-4c21-baf0-01a813ccc6ac (just
> the uuid wouldnt work) and this is probably the most important thing
> to do.it worked!
> I also set the resume variable in initramfs to my swap partition but
> this might nor be so important anyway since it's automatically
> detected.
>=20
> I tested both systemctl hibernate and pm-hibernate, i guess they call
> the same thing anyway. I attached a screenshot. Seems to be working
> fine without uswsusp and with nvidia proprietary drivers!
>=20
> On Wed, Apr 3, 2019 at 2:55 PM Rainer Fiebig <jrf@mailbox.org> wrote:
>>
>> Am 03.04.19 um 18:59 schrieb Matheus Fillipe:
>>> Yes I can sorta confirm the bug is in uswsusp. I removed the package
>>> and pm-utils
>>
>> Matheus,
>>
>> there is no need to uninstall pm-utils. You actually need this to have=

>> comfortable suspend/hibernate.
>>
>> The only additional option you will get from uswsusp is true s2both
>> (which is nice, imo).
>>
>> pm-utils provides something similar called "suspend-hybrid" which mean=
s
>> that the computer suspends and after a configurable time wakes up agai=
n
>> to go into hibernation.
>>
>> and used both "systemctl hibernate"  and "echo disk >>
>>> /sys/power/state" to hibernate. It seems to succeed and shuts down, I=

>>> am just not able to resume from it, which seems to be a classical
>>> problem solved just by setting the resume swap file/partition on grub=
=2E
>>> (which i tried and didn't work even with nvidia disabled)
>>>
>>> Anyway uswsusp is still necessary because the default kernel
>>> hibernation doesn't work with the proprietary nvidia drivers as long
>>> as I know  and tested.
>>
>> What doesn't work: hibernating or resuming?
>> And /var/log/pm-suspend.log might give you a clue what causes the prob=
lem.
>>
>>>
>>> Is there anyway I could get any workaround to this bug on my current
>>> OS by the way?
>>
>> *I* don't know, I don't use Ubuntu. But what I would do now is
>> re-install pm-utils *without* uswsusp and make sure that you have got
>> the swap-partition/file right in grub.cfg or menu.lst (grub legacy).
>>
>> Then do a few pm-hibernate/resume and tell us what happened.
>>
>> So long!
>>
>>>
>>> On Wed, Apr 3, 2019 at 7:04 AM Rainer Fiebig <jrf@mailbox.org> wrote:=

>>>>
>>>> Am 03.04.19 um 11:34 schrieb Jan Kara:
>>>>> On Tue 02-04-19 16:25:00, Andrew Morton wrote:
>>>>>>
>>>>>> I cc'ed a bunch of people from bugzilla.
>>>>>>
>>>>>> Folks, please please please remember to reply via emailed
>>>>>> reply-to-all.  Don't use the bugzilla interface!
>>>>>>
>>>>>> On Mon, 16 Jun 2014 18:29:26 +0200 "Rafael J. Wysocki" <rafael.j.w=
ysocki@intel.com> wrote:
>>>>>>
>>>>>>> On 6/13/2014 6:55 AM, Johannes Weiner wrote:
>>>>>>>> On Fri, Jun 13, 2014 at 01:50:47AM +0200, Rafael J. Wysocki wrot=
e:
>>>>>>>>> On 6/13/2014 12:02 AM, Johannes Weiner wrote:
>>>>>>>>>> On Tue, May 06, 2014 at 01:45:01AM +0200, Rafael J. Wysocki wr=
ote:
>>>>>>>>>>> On 5/6/2014 1:33 AM, Johannes Weiner wrote:
>>>>>>>>>>>> Hi Oliver,
>>>>>>>>>>>>
>>>>>>>>>>>> On Mon, May 05, 2014 at 11:00:13PM +0200, Oliver Winker wrot=
e:
>>>>>>>>>>>>> Hello,
>>>>>>>>>>>>>
>>>>>>>>>>>>> 1) Attached a full function-trace log + other SysRq outputs=
, see [1]
>>>>>>>>>>>>> attached.
>>>>>>>>>>>>>
>>>>>>>>>>>>> I saw bdi_...() calls in the s2disk paths, but didn't check=
 in detail
>>>>>>>>>>>>> Probably more efficient when one of you guys looks directly=
=2E
>>>>>>>>>>>> Thanks, this looks interesting.  balance_dirty_pages() wakes=
 up the
>>>>>>>>>>>> bdi_wq workqueue as it should:
>>>>>>>>>>>>
>>>>>>>>>>>> [  249.148009]   s2disk-3327    2.... 48550413us : global_di=
rty_limits <-balance_dirty_pages_ratelimited
>>>>>>>>>>>> [  249.148009]   s2disk-3327    2.... 48550414us : global_di=
rtyable_memory <-global_dirty_limits
>>>>>>>>>>>> [  249.148009]   s2disk-3327    2.... 48550414us : writeback=
_in_progress <-balance_dirty_pages_ratelimited
>>>>>>>>>>>> [  249.148009]   s2disk-3327    2.... 48550414us : bdi_start=
_background_writeback <-balance_dirty_pages_ratelimited
>>>>>>>>>>>> [  249.148009]   s2disk-3327    2.... 48550414us : mod_delay=
ed_work_on <-balance_dirty_pages_ratelimited
>>>>>>>>>>>> but the worker wakeup doesn't actually do anything:
>>>>>>>>>>>> [  249.148009] kworker/-3466    2d... 48550431us : finish_ta=
sk_switch <-__schedule
>>>>>>>>>>>> [  249.148009] kworker/-3466    2.... 48550431us : _raw_spin=
_lock_irq <-worker_thread
>>>>>>>>>>>> [  249.148009] kworker/-3466    2d... 48550431us : need_to_c=
reate_worker <-worker_thread
>>>>>>>>>>>> [  249.148009] kworker/-3466    2d... 48550432us : worker_en=
ter_idle <-worker_thread
>>>>>>>>>>>> [  249.148009] kworker/-3466    2d... 48550432us : too_many_=
workers <-worker_enter_idle
>>>>>>>>>>>> [  249.148009] kworker/-3466    2.... 48550432us : schedule =
<-worker_thread
>>>>>>>>>>>> [  249.148009] kworker/-3466    2.... 48550432us : __schedul=
e <-worker_thread
>>>>>>>>>>>>
>>>>>>>>>>>> My suspicion is that this fails because the bdi_wq is frozen=
 at this
>>>>>>>>>>>> point and so the flush work never runs until resume, whereas=
 before my
>>>>>>>>>>>> patch the effective dirty limit was high enough so that imag=
e could be
>>>>>>>>>>>> written in one go without being throttled; followed by an fs=
ync() that
>>>>>>>>>>>> then writes the pages in the context of the unfrozen s2disk.=

>>>>>>>>>>>>
>>>>>>>>>>>> Does this make sense?  Rafael?  Tejun?
>>>>>>>>>>> Well, it does seem to make sense to me.
>>>>>>>>>>  From what I see, this is a deadlock in the userspace suspend =
model and
>>>>>>>>>> just happened to work by chance in the past.
>>>>>>>>> Well, it had been working for quite a while, so it was a rather=
 large
>>>>>>>>> opportunity
>>>>>>>>> window it seems. :-)
>>>>>>>> No doubt about that, and I feel bad that it broke.  But it's sti=
ll a
>>>>>>>> deadlock that can't reasonably be accommodated from dirty thrott=
ling.
>>>>>>>>
>>>>>>>> It can't just put the flushers to sleep and then issue a large a=
mount
>>>>>>>> of buffered IO, hoping it doesn't hit the dirty limits.  Don't s=
hoot
>>>>>>>> the messenger, this bug needs to be addressed, not get papered o=
ver.
>>>>>>>>
>>>>>>>>>> Can we patch suspend-utils as follows?
>>>>>>>>> Perhaps we can.  Let's ask the new maintainer.
>>>>>>>>>
>>>>>>>>> Rodolfo, do you think you can apply the patch below to suspend-=
utils?
>>>>>>>>>
>>>>>>>>>> Alternatively, suspend-utils
>>>>>>>>>> could clear the dirty limits before it starts writing and rest=
ore them
>>>>>>>>>> post-resume.
>>>>>>>>> That (and the patch too) doesn't seem to address the problem wi=
th existing
>>>>>>>>> suspend-utils
>>>>>>>>> binaries, however.
>>>>>>>> It's userspace that freezes the system before issuing buffered I=
O, so
>>>>>>>> my conclusion was that the bug is in there.  This is arguable.  =
I also
>>>>>>>> wouldn't be opposed to a patch that sets the dirty limits to inf=
inity
>>>>>>>> from the ioctl that freezes the system or creates the image.
>>>>>>>
>>>>>>> OK, that sounds like a workable plan.
>>>>>>>
>>>>>>> How do I set those limits to infinity?
>>>>>>
>>>>>> Five years have passed and people are still hitting this.
>>>>>>
>>>>>> Killian described the workaround in comment 14 at
>>>>>> https://bugzilla.kernel.org/show_bug.cgi?id=3D75101.
>>>>>>
>>>>>> People can use this workaround manually by hand or in scripts.  Bu=
t we
>>>>>> really should find a proper solution.  Maybe special-case the free=
zing
>>>>>> of the flusher threads until all the writeout has completed.  Or
>>>>>> something else.
>>>>>
>>>>> I've refreshed my memory wrt this bug and I believe the bug is real=
ly on
>>>>> the side of suspend-utils (uswsusp or however it is called). They a=
re low
>>>>> level system tools, they ask the kernel to freeze all processes
>>>>> (SNAPSHOT_FREEZE ioctl), and then they rely on buffered writeback (=
which is
>>>>> relatively heavyweight infrastructure) to work. That is wrong in my=

>>>>> opinion.
>>>>>
>>>>> I can see Johanness was suggesting in comment 11 to use O_SYNC in
>>>>> suspend-utils which worked but was too slow. Indeed O_SYNC is rathe=
r big
>>>>> hammer but using O_DIRECT should be what they need and get better
>>>>> performance - no additional buffering in the kernel, no dirty throt=
tling,
>>>>> etc. They only need their buffer & device offsets sector aligned - =
they
>>>>> seem to be even page aligned in suspend-utils so they should be fin=
e. And
>>>>> if the performance still sucks (currently they appear to do mostly =
random
>>>>> 4k writes so it probably would for rotating disks), they could use =
AIO DIO
>>>>> to get multiple pages in flight (as many as they dare to allocate b=
uffers)
>>>>> and then the IO scheduler will reorder things as good as it can and=
 they
>>>>> should get reasonable performance.
>>>>>
>>>>> Is there someone who works on suspend-utils these days? Because the=
 repo
>>>>> I've found on kernel.org seems to be long dead (last commit in 2012=
).
>>>>>
>>>>>                                                               Honza=

>>>>>
>>>>
>>>> Whether it's suspend-utils (or uswsusp) or not could be answered qui=
ckly
>>>> by de-installing this package and using the kernel-methods instead.
>>>>
>>>>
>>
>>

So you got hibernate working now with pm-utils *and* the prop. Nvidia
drivers. That's good - although a bit contrary to what you said in
Comment 29:

> Anyway uswsusp is still necessary because the default kernel
> hibernation doesn't work with the proprietary nvidia drivers as long
> as I know  and tested

Never mind. Stick with it if you don't need s2both.

What still puzzles me is that while others are having problems,
suspend-utils/uswsusp work for me almost 100 % of the time, except for a
few extreme test-cases in the past. You also said that it worked
"flawlessly" for you until you upgraded your system.

So I'm wondering whether used-up swap space might play a role in this
matter, too. At least for the cases that I've seen on my system, I can't
rule this out. And when I look at the screenshot you provided in Comment
27 (https://launchpadlibrarian.net/417327528/i915.jpg), sparse
swap-space could have been a factor in that case as well. Because
roughly 3.5 GB free swap-space doesn't seem much for a 16-GB-RAM box.


--4x6JFQYtFRGjXrc3IWkjK6HSONjtqIxak--

--5hDTI6kuNPaeZpVR9mGMDtYctWudSR8l3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEE6yx5PjBNuGB2qJXG8OH3JiWK+PUFAlyl4TAACgkQ8OH3JiWK
+PXRwA//eTLs6eJUKhTC3EV6XUpDl9mCMTREWH8vmkmXjNyzSi0D3a1ctmwNdsdE
sOa5mwrHUCBhEdc/hSKJOl9iKtLANWKS74LMp44XdJkuXnXSdii9c+2zkxgDzIE4
O3v+MdfXsdJBYfqelM6RgHaHiDyVfK+v2kGQb9NUDWG6fWfYQvOuISwm3WOCjvZa
dJIoUL1kQqA+S0GpD5ClG9tpWRUgV1V384MIcydxb2+Q1ZRXwwPJ7ep9cS4MfX+4
p5mbYns+kfb2pZrMxaUiTyXO7QcLgk0dnwoxPGlz0iGfmIRv7bkPdSJkKfKkZgCG
nE5GBzRp6EitFLXOd24epqT4O+0sMo512Z8aBlkyMXRrZd3jej6VUMEClUZ9DSzI
8phtZL8OIBphylRUmNqQ+k+bC3jb0Q6Rkcxji/BDR0dYM2UH1z9+ZO9taLWGxvwE
nqJkfKG8ARlj7Lq4A0vrwAk6kiwz5+VeI0z82N5v1g0OYnENSbMwEgKcike9ZxTI
iGTN2K3r9Fq+W3Q4Gz3PMYClSJGdbOGxDHF3ioxz2Vb4mBSr8Wu7s4Y49thRlaBO
FsIE5SeB3I512UNqdM6p/dV+xzi//NAKcmgCPCNBji1JCfhzu6RJQ6aBYhb+owYb
FuNdy5fMrhY3NfqJw879LDL3qSC/9qjt9FI4U9GxbTqeEfRlgEQ=
=czgF
-----END PGP SIGNATURE-----

--5hDTI6kuNPaeZpVR9mGMDtYctWudSR8l3--

