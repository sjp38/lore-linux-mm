Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 084B4C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:56:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91AD32084B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:56:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=mailbox.org header.i=@mailbox.org header.b="O5l7RbIo";
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=mailbox.org header.i=@mailbox.org header.b="WTgfttP4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91AD32084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mailbox.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 199706B000C; Wed,  3 Apr 2019 13:56:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14B2F6B027C; Wed,  3 Apr 2019 13:56:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2D7E6B027D; Wed,  3 Apr 2019 13:55:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9B40F6B000C
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 13:55:59 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id 41so8013043edq.0
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 10:55:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:mime-version
         :in-reply-to;
        bh=rWRHcqS+a4ekNJLhk+Pvz6trXx+iCzTLiXJyfPWDHQM=;
        b=ago6JAwE3TXfW02OvUP5cKqI8PBASqaNBZ56Ru7BylfC7DGd5EvDs/fGwudyp645ar
         SpROnLT5CVHoFVXBDAht2VpX2N0Mhi6MA6tQqy34kuBoyM/rRjd/0OfMSRIiaFm7EPPu
         rdOuAwHdI5njsZKyQ3WS609UPEejbBk7OuCApoci2GlxCnyIkAB3pM/XGCNpXvcBaImj
         Z4tEbq53kO9IfxjDRpzZ2K/hEa2Sk4MYrJ6FgfaMTTG+sMTPfIVtcr/vUitjcjgwNmxR
         q3zsn67PUUitcpp6C+ncKllN9ZKSF7Hszf1atQVl+ICeBsaPQGSXlN1WseeSW42rWG1X
         fT5A==
X-Gm-Message-State: APjAAAVyP8mViQ9XLRjMFNNHFvnnW86khdvU2RfRRoDc0212dEcej5FG
	9a9nt7Ha+6WHFWyCY0OUJqdhvutGnKquQD4+cGGIiSn1H9SCXI6TCfQTQfSK3wmLV3X66Jt5KKA
	NVZCqS8bwtCWML+ai+0NuKQ2nadi54CsDg+KrbMbsvGdH6lJpmXKpR1KCJUT33PHodA==
X-Received: by 2002:a50:ac04:: with SMTP id v4mr613819edc.255.1554314158995;
        Wed, 03 Apr 2019 10:55:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJ/8M4C5JGzdIu/pLW/eSfSZvDb1Uqg6OHMM4ehOwfbwtD2Ssb7q664SPBlNFvQKJrdPF2
X-Received: by 2002:a50:ac04:: with SMTP id v4mr613768edc.255.1554314157723;
        Wed, 03 Apr 2019 10:55:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554314157; cv=none;
        d=google.com; s=arc-20160816;
        b=QnOoum8jdg5OwZKSm3URlH4XDdWcmDTrAYJfVYG7VrtfUwjBd4/JmNaa1IpkaPFHaN
         TDdnCiDuvB4MzCLWeEi2fbWdU6+EiAjLQMuQV3pDtTVaRtC1BBlpbz2CNl5G4klMYnZI
         WVF0sul1uxHkak3LoaGEvO/HMyL4QayZvFTn0OzI2lFgCwbfuz7LkV1kQR+uScUCozM6
         gsvQdS2gOcDralbBR35i+Nr9mliYYmjbKPSdu39t2d54yLnWQj8zHJEq7TwrZiV2PsO8
         1vSXLCx/9keBcAOzoRZon3VRtP41Uj05ph455XEW1VpSO8yZRa895gTMhRkeFNtjs9tn
         MeLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:date:message-id:autocrypt:openpgp:from
         :references:cc:to:subject:dkim-signature:dkim-signature;
        bh=rWRHcqS+a4ekNJLhk+Pvz6trXx+iCzTLiXJyfPWDHQM=;
        b=O8e0Pp3X1wxUUiYP46+dOqxL8U1EIXFWb0UuHhlE8eNR3154DlZPMS5jRQ35BYLWcv
         sF+BIX7KQPOG0djUtdWM/VzTRS6+5IoxsSt3msEnxqh1KnDItNo2hqrlODt92cSKILVw
         NlljOILnFVkagsElLrkuZtHTt8mOZfV/HDB0TyRKRLWure2AesZffZJTOiWZLtxJkkQl
         5R5o3V7bRBahEoaQCSR+CDq5xp1uOyyCeZnM70NcYUQKw1b0rm9UYvijqkqNqXMlfa0Y
         b98epqpBnTojUaAibBhTakueQD5CBXi21ujbosQgE55RBskk0epr+meBUNLl2iVsgF8t
         MR/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@mailbox.org header.s=mail20150812 header.b=O5l7RbIo;
       dkim=pass header.i=@mailbox.org header.s=mail20150812 header.b=WTgfttP4;
       spf=pass (google.com: domain of jrf@mailbox.org designates 2001:67c:2050:104:0:1:25:1 as permitted sender) smtp.mailfrom=jrf@mailbox.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mailbox.org
Received: from mx1.mailbox.org (mx1.mailbox.org. [2001:67c:2050:104:0:1:25:1])
        by mx.google.com with ESMTPS id q1si2280974ejr.44.2019.04.03.10.55.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Apr 2019 10:55:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrf@mailbox.org designates 2001:67c:2050:104:0:1:25:1 as permitted sender) client-ip=2001:67c:2050:104:0:1:25:1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@mailbox.org header.s=mail20150812 header.b=O5l7RbIo;
       dkim=pass header.i=@mailbox.org header.s=mail20150812 header.b=WTgfttP4;
       spf=pass (google.com: domain of jrf@mailbox.org designates 2001:67c:2050:104:0:1:25:1 as permitted sender) smtp.mailfrom=jrf@mailbox.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mailbox.org
Received: from smtp1.mailbox.org (smtp1.mailbox.org [IPv6:2001:67c:2050:105:465:1:1:0])
	(using TLSv1.2 with cipher ECDHE-RSA-CHACHA20-POLY1305 (256/256 bits))
	(No client certificate requested)
	by mx1.mailbox.org (Postfix) with ESMTPS id D02714E15C;
	Wed,  3 Apr 2019 19:55:55 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=mailbox.org; h=
	content-type:content-type:in-reply-to:mime-version:date:date
	:message-id:from:from:references:subject:subject:received; s=
	mail20150812; t=1554314150; bh=xFjoNSzLJgZ7Rq46MvtiVSunhvUOjN/qW
	S9OIF+rAuc=; b=O5l7RbIoXtg/nEGyvtRhbLUqMyh5l6JnsRgZXQVz60c9te+SY
	NtXs1Duz41BLOEAYkPY3DU55f0SOwmvIhAKZkIplLje0szwzS6Puj505Kfer6RIZ
	T6aDv1ZyVkVGZMOnxP/j0Dz3IfAVVm8sokoi1J/t76qPrPf1DQFwU85spGA/Mkbr
	dz1D8nvcLCdgWqvgQMWRVmkhpr9Q3o7UfzLyFIb385dufuT5Oin4YX9jJCk27JVf
	jDZr4i8zjx/FgnchGggvKHyEKo5gXu6BetYMQiPsZkTrQd28FHxb/7KL667zDvfg
	c3YSxVkexOZWNIkS9RFhTmqfh/tx+iX0iT6Mg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=mailbox.org; s=mail20150812;
	t=1554314153; h=from:from:sender:reply-to:subject:subject:date:date:
	 message-id:message-id:to:to:cc:cc:mime-version:mime-version:
	 content-type:content-type:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=rWRHcqS+a4ekNJLhk+Pvz6trXx+iCzTLiXJyfPWDHQM=;
	b=WTgfttP40LGIeodogJmdd64SkF/UH3n2j+5oCNwQFfEANawpHtmSetZ7f+iKR/FJFcmbt/
	iItwf/3/FnrOLe3ysmM31h5+GX9m6efZR81x7Vfoo9bQpMrTJujEI3rPIpo4U8Wc9JxLtg
	bmIbpCCgEQF00CAN+4tcyNTGaR/nye+N0Cnv095vv2Dg36OhhyJ57sjkcY1ZC2FA1QqtGq
	GJHEZgeAPCea9+6eofUYUTjcgRenMXFEiVsKVqzwDXyH3jgHyFdUvdgbbdWDQBrL1V8bMe
	1HwZcLC72P7P2Dus/eqAZ/q+yWlOrR6bmT0QBdwIi0Ulv2y1RBaV6V4LzgnFgg==
X-Virus-Scanned: amavisd-new at heinlein-support.de
Received: from smtp1.mailbox.org ([80.241.60.240])
	by spamfilter04.heinlein-hosting.de (spamfilter04.heinlein-hosting.de [80.241.56.122]) (amavisd-new, port 10030)
	with ESMTP id TB4b166A3IZj; Wed,  3 Apr 2019 19:55:50 +0200 (CEST)
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
From: Rainer Fiebig <jrf@mailbox.org>
Openpgp: preference=signencrypt
Autocrypt: addr=jrf@mailbox.org; prefer-encrypt=mutual; keydata=
 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
 SJBEfJI=
Message-ID: <56c1efb7-142b-9ae3-7f59-852d739f6632@mailbox.org>
Date: Wed, 3 Apr 2019 19:55:59 +0200
MIME-Version: 1.0
In-Reply-To: <CAFWuBvcS-8AFZ4KoimMrLPjFXGE8a48QnSqV3_gajJNWYZymGA@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="OT5peTUN2HwQfjAywuN98OEQtF9FprUNr"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--OT5peTUN2HwQfjAywuN98OEQtF9FprUNr
Content-Type: multipart/mixed; boundary="CxpyVZSynJuVFsL1CbY7LZchOlCBlamOS";
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
Message-ID: <56c1efb7-142b-9ae3-7f59-852d739f6632@mailbox.org>
Subject: Re: [Bug 75101] New: [bisected] s2disk / hibernate blocks on "Saving
 506031 image data pages () ..."
References: <20140505233358.GC19914@cmpxchg.org> <5368227D.7060302@intel.com>
 <20140612220200.GA25344@cmpxchg.org> <539A3CD7.6080100@intel.com>
 <20140613045557.GL2878@cmpxchg.org> <539F1B66.2020006@intel.com>
 <20190402162500.def729ec05e6e267bff8a5da@linux-foundation.org>
 <20190403093432.GD8836@quack2.suse.cz>
 <1ea9f923-4756-85b2-6092-6d9e94d576a1@mailbox.org>
 <CAFWuBvcS-8AFZ4KoimMrLPjFXGE8a48QnSqV3_gajJNWYZymGA@mail.gmail.com>
In-Reply-To: <CAFWuBvcS-8AFZ4KoimMrLPjFXGE8a48QnSqV3_gajJNWYZymGA@mail.gmail.com>

--CxpyVZSynJuVFsL1CbY7LZchOlCBlamOS
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Am 03.04.19 um 18:59 schrieb Matheus Fillipe:
> Yes I can sorta confirm the bug is in uswsusp. I removed the package
> and pm-utils=20

Matheus,

there is no need to uninstall pm-utils. You actually need this to have
comfortable suspend/hibernate.

The only additional option you will get from uswsusp is true s2both
(which is nice, imo).

pm-utils provides something similar called "suspend-hybrid" which means
that the computer suspends and after a configurable time wakes up again
to go into hibernation.

and used both "systemctl hibernate"  and "echo disk >>
> /sys/power/state" to hibernate. It seems to succeed and shuts down, I
> am just not able to resume from it, which seems to be a classical
> problem solved just by setting the resume swap file/partition on grub.
> (which i tried and didn't work even with nvidia disabled)
>=20
> Anyway uswsusp is still necessary because the default kernel
> hibernation doesn't work with the proprietary nvidia drivers as long
> as I know  and tested.

What doesn't work: hibernating or resuming?
And /var/log/pm-suspend.log might give you a clue what causes the problem=
=2E

>=20
> Is there anyway I could get any workaround to this bug on my current
> OS by the way?

*I* don't know, I don't use Ubuntu. But what I would do now is
re-install pm-utils *without* uswsusp and make sure that you have got
the swap-partition/file right in grub.cfg or menu.lst (grub legacy).

Then do a few pm-hibernate/resume and tell us what happened.

So long!

>=20
> On Wed, Apr 3, 2019 at 7:04 AM Rainer Fiebig <jrf@mailbox.org> wrote:
>>
>> Am 03.04.19 um 11:34 schrieb Jan Kara:
>>> On Tue 02-04-19 16:25:00, Andrew Morton wrote:
>>>>
>>>> I cc'ed a bunch of people from bugzilla.
>>>>
>>>> Folks, please please please remember to reply via emailed
>>>> reply-to-all.  Don't use the bugzilla interface!
>>>>
>>>> On Mon, 16 Jun 2014 18:29:26 +0200 "Rafael J. Wysocki" <rafael.j.wys=
ocki@intel.com> wrote:
>>>>
>>>>> On 6/13/2014 6:55 AM, Johannes Weiner wrote:
>>>>>> On Fri, Jun 13, 2014 at 01:50:47AM +0200, Rafael J. Wysocki wrote:=

>>>>>>> On 6/13/2014 12:02 AM, Johannes Weiner wrote:
>>>>>>>> On Tue, May 06, 2014 at 01:45:01AM +0200, Rafael J. Wysocki wrot=
e:
>>>>>>>>> On 5/6/2014 1:33 AM, Johannes Weiner wrote:
>>>>>>>>>> Hi Oliver,
>>>>>>>>>>
>>>>>>>>>> On Mon, May 05, 2014 at 11:00:13PM +0200, Oliver Winker wrote:=

>>>>>>>>>>> Hello,
>>>>>>>>>>>
>>>>>>>>>>> 1) Attached a full function-trace log + other SysRq outputs, =
see [1]
>>>>>>>>>>> attached.
>>>>>>>>>>>
>>>>>>>>>>> I saw bdi_...() calls in the s2disk paths, but didn't check i=
n detail
>>>>>>>>>>> Probably more efficient when one of you guys looks directly.
>>>>>>>>>> Thanks, this looks interesting.  balance_dirty_pages() wakes u=
p the
>>>>>>>>>> bdi_wq workqueue as it should:
>>>>>>>>>>
>>>>>>>>>> [  249.148009]   s2disk-3327    2.... 48550413us : global_dirt=
y_limits <-balance_dirty_pages_ratelimited
>>>>>>>>>> [  249.148009]   s2disk-3327    2.... 48550414us : global_dirt=
yable_memory <-global_dirty_limits
>>>>>>>>>> [  249.148009]   s2disk-3327    2.... 48550414us : writeback_i=
n_progress <-balance_dirty_pages_ratelimited
>>>>>>>>>> [  249.148009]   s2disk-3327    2.... 48550414us : bdi_start_b=
ackground_writeback <-balance_dirty_pages_ratelimited
>>>>>>>>>> [  249.148009]   s2disk-3327    2.... 48550414us : mod_delayed=
_work_on <-balance_dirty_pages_ratelimited
>>>>>>>>>> but the worker wakeup doesn't actually do anything:
>>>>>>>>>> [  249.148009] kworker/-3466    2d... 48550431us : finish_task=
_switch <-__schedule
>>>>>>>>>> [  249.148009] kworker/-3466    2.... 48550431us : _raw_spin_l=
ock_irq <-worker_thread
>>>>>>>>>> [  249.148009] kworker/-3466    2d... 48550431us : need_to_cre=
ate_worker <-worker_thread
>>>>>>>>>> [  249.148009] kworker/-3466    2d... 48550432us : worker_ente=
r_idle <-worker_thread
>>>>>>>>>> [  249.148009] kworker/-3466    2d... 48550432us : too_many_wo=
rkers <-worker_enter_idle
>>>>>>>>>> [  249.148009] kworker/-3466    2.... 48550432us : schedule <-=
worker_thread
>>>>>>>>>> [  249.148009] kworker/-3466    2.... 48550432us : __schedule =
<-worker_thread
>>>>>>>>>>
>>>>>>>>>> My suspicion is that this fails because the bdi_wq is frozen a=
t this
>>>>>>>>>> point and so the flush work never runs until resume, whereas b=
efore my
>>>>>>>>>> patch the effective dirty limit was high enough so that image =
could be
>>>>>>>>>> written in one go without being throttled; followed by an fsyn=
c() that
>>>>>>>>>> then writes the pages in the context of the unfrozen s2disk.
>>>>>>>>>>
>>>>>>>>>> Does this make sense?  Rafael?  Tejun?
>>>>>>>>> Well, it does seem to make sense to me.
>>>>>>>>  From what I see, this is a deadlock in the userspace suspend mo=
del and
>>>>>>>> just happened to work by chance in the past.
>>>>>>> Well, it had been working for quite a while, so it was a rather l=
arge
>>>>>>> opportunity
>>>>>>> window it seems. :-)
>>>>>> No doubt about that, and I feel bad that it broke.  But it's still=
 a
>>>>>> deadlock that can't reasonably be accommodated from dirty throttli=
ng.
>>>>>>
>>>>>> It can't just put the flushers to sleep and then issue a large amo=
unt
>>>>>> of buffered IO, hoping it doesn't hit the dirty limits.  Don't sho=
ot
>>>>>> the messenger, this bug needs to be addressed, not get papered ove=
r.
>>>>>>
>>>>>>>> Can we patch suspend-utils as follows?
>>>>>>> Perhaps we can.  Let's ask the new maintainer.
>>>>>>>
>>>>>>> Rodolfo, do you think you can apply the patch below to suspend-ut=
ils?
>>>>>>>
>>>>>>>> Alternatively, suspend-utils
>>>>>>>> could clear the dirty limits before it starts writing and restor=
e them
>>>>>>>> post-resume.
>>>>>>> That (and the patch too) doesn't seem to address the problem with=
 existing
>>>>>>> suspend-utils
>>>>>>> binaries, however.
>>>>>> It's userspace that freezes the system before issuing buffered IO,=
 so
>>>>>> my conclusion was that the bug is in there.  This is arguable.  I =
also
>>>>>> wouldn't be opposed to a patch that sets the dirty limits to infin=
ity
>>>>>> from the ioctl that freezes the system or creates the image.
>>>>>
>>>>> OK, that sounds like a workable plan.
>>>>>
>>>>> How do I set those limits to infinity?
>>>>
>>>> Five years have passed and people are still hitting this.
>>>>
>>>> Killian described the workaround in comment 14 at
>>>> https://bugzilla.kernel.org/show_bug.cgi?id=3D75101.
>>>>
>>>> People can use this workaround manually by hand or in scripts.  But =
we
>>>> really should find a proper solution.  Maybe special-case the freezi=
ng
>>>> of the flusher threads until all the writeout has completed.  Or
>>>> something else.
>>>
>>> I've refreshed my memory wrt this bug and I believe the bug is really=
 on
>>> the side of suspend-utils (uswsusp or however it is called). They are=
 low
>>> level system tools, they ask the kernel to freeze all processes
>>> (SNAPSHOT_FREEZE ioctl), and then they rely on buffered writeback (wh=
ich is
>>> relatively heavyweight infrastructure) to work. That is wrong in my
>>> opinion.
>>>
>>> I can see Johanness was suggesting in comment 11 to use O_SYNC in
>>> suspend-utils which worked but was too slow. Indeed O_SYNC is rather =
big
>>> hammer but using O_DIRECT should be what they need and get better
>>> performance - no additional buffering in the kernel, no dirty throttl=
ing,
>>> etc. They only need their buffer & device offsets sector aligned - th=
ey
>>> seem to be even page aligned in suspend-utils so they should be fine.=
 And
>>> if the performance still sucks (currently they appear to do mostly ra=
ndom
>>> 4k writes so it probably would for rotating disks), they could use AI=
O DIO
>>> to get multiple pages in flight (as many as they dare to allocate buf=
fers)
>>> and then the IO scheduler will reorder things as good as it can and t=
hey
>>> should get reasonable performance.
>>>
>>> Is there someone who works on suspend-utils these days? Because the r=
epo
>>> I've found on kernel.org seems to be long dead (last commit in 2012).=

>>>
>>>                                                               Honza
>>>
>>
>> Whether it's suspend-utils (or uswsusp) or not could be answered quick=
ly
>> by de-installing this package and using the kernel-methods instead.
>>
>>



--CxpyVZSynJuVFsL1CbY7LZchOlCBlamOS--

--OT5peTUN2HwQfjAywuN98OEQtF9FprUNr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEE6yx5PjBNuGB2qJXG8OH3JiWK+PUFAlyk88IACgkQ8OH3JiWK
+PWaAg//RkBMB/m6BhGhrshaln94vDFQQKBRunqKoBuacvG9H4UcLlFezFVRQgpK
iP7T4k6WJ19BhF1oSoL7tYQOUt3iFnrnpzbE6uBBsD+73YYNH+qQzvjO7o2KruUj
QYuU3ogZAHC6dwUbJ7lFfIhaSqFLk1uODaRQaaC8jEgIst1hzICVVnnRAyntzpvZ
h5c7hoJL72WQpwwFrBosWmjEFw6+a0xGsfqCCQN/0ITi2mjiUSt/ZVxytD2tsmFu
s1mSxye2/P/3LXRgUWJSkPFNTu0QT+uPGQH+UriE81mQlEPpzBCRIXcbxDS77dIb
Z/+HkE2IShp2I+BlgPFdm38QUVgkE62Yod/TZEOf1TpoISv7XBOBtIcL+oXRc/76
sQNBGr/BWg1LBFirNQORZ6RtHYL9fey5LS8X8E/XXi2/hgWx2/RzJs2+VrMeKiyZ
gezXYJnhITswGvzGuEozPXlkyJzLAnjmBk6YFX2eW9BrxOtuiCnEd+I8ELuCpG/2
RXRF0wJwyrV94df8rr2L/O11MytwdrumFMZmF6gHKGpVIUMv4KJQlq+bNkPaE4gf
5Zfg6fqOncC4IL+ZclV4rK6HwUFEryiOZpye4txPJotBpfgl41AGFGtr7uLMz8+C
xsnoOKU1Vt+SR4RjHdvCNyliRZMX6121XOGcIIFsfZ/jfi1IpcM=
=KFZ1
-----END PGP SIGNATURE-----

--OT5peTUN2HwQfjAywuN98OEQtF9FprUNr--

