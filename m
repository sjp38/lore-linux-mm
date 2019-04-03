Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC129C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 10:04:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87D2720643
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 10:04:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=mailbox.org header.i=@mailbox.org header.b="kiqjLJJr";
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=mailbox.org header.i=@mailbox.org header.b="Y4b61l7C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87D2720643
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mailbox.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 14DE66B0008; Wed,  3 Apr 2019 06:04:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FF1C6B000A; Wed,  3 Apr 2019 06:04:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE1236B000C; Wed,  3 Apr 2019 06:04:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9793A6B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 06:04:14 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m31so7261273edm.4
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 03:04:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:mime-version
         :in-reply-to;
        bh=R9Q6QIVKc468781lbTx4PhwohQZ4v5n+95uMustBFJo=;
        b=uHbBzmHABz02YCsEv9jL/SqOmDywZZoWQR5n8M0vZIn8eiDQy8fUu0pff2YnN5egRf
         +vgGgKEGsRRLwuosv8LGegRAPFdl7zy8U/ZcyS9eU9tHMmrkDJEY4sCtMDgwe1Nd8e9L
         TFIxw1L3qWM+bODFZoBReL0jJ2aUn/mWFs5XZ3eWFsf3B50NMoJoOsyoKSDih1Yp1KZx
         AQ0VjCk/x+Vt/CG1mmDsYy5K5LW53dfXWCUy1Ljn+szZj8g0SkwMvrx7tfI1JfvTgY58
         xTU0U7crXsK17M8cm3fRjabFo1MgTTycF5cg+3cx4lwFHKvOiAjadz1HNBKNvb6p5WpU
         yKsw==
X-Gm-Message-State: APjAAAVcQPM0Kg59p+P1cgGv9ts5kuyHkqcyMjMjTMajLrqG8iSkdM2J
	g5XdwOFjMomsUMm7SU80irLTiz5Fwkkw+Zs4KVvsCGS6ZlHqpJpi1h+/FkQgZHYrCkTZMaSRQRh
	GvdRPT9bF6Y3JiIOy9Oyz0O1pQX91z1xDprwHHxt9SUgiqJLDYHK90lTsPNG2rKoxJw==
X-Received: by 2002:a50:9e6b:: with SMTP id z98mr134232ede.174.1554285854135;
        Wed, 03 Apr 2019 03:04:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsUXFqc+aKDpF7IA/piJYDwPNCoNiLN0+EWsV13uxH11vxpMH6NOtgD6VO6zlLn5/Nro/x
X-Received: by 2002:a50:9e6b:: with SMTP id z98mr134155ede.174.1554285852730;
        Wed, 03 Apr 2019 03:04:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554285852; cv=none;
        d=google.com; s=arc-20160816;
        b=HF/s8lK2g8TPI2cFOBQz8q1tNzdSPbGD2GPM+rcpVEluY1lHAAREDWPMCqn1ZirpsE
         P7t/MfGW5YM1OFc7L40RxB9UjrmriEtqbS9DBsUX8k0d3Kal7GJFpysRoe+lwfBjG8j7
         EwOb9exLYalYukdO8c0qI0h4/wpD3Wl/RKeHuHu6gbW2r0xy3bNvnrpC9cLlfIAZZ5Z+
         1PsOD2nl6tTtDxj0IfegC2Pgw1SlQIhRz6EWecEGCLJGx+f/rY+jEdMMYoAH6xS6V5Sj
         hIGjMwq2kJdsfa9rtBaoFoPzFM+SZfFxsG+cBADD3TYYJQpdSHIBziBZxBLP6bt13UAE
         crtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:date:message-id:autocrypt:openpgp:from
         :references:cc:to:subject:dkim-signature:dkim-signature;
        bh=R9Q6QIVKc468781lbTx4PhwohQZ4v5n+95uMustBFJo=;
        b=s+Ano9kJMxd8RNsLQ107bxbRJHJ4DWT25uQ3kXnW8LbKa4V2HgykGce4Sc/tqIP8kL
         JeQ0wIdpm97QvmntDRyJrt568IuXtpdTmYjADs45rEODrTdB57f5soGvT2GYNc7n/fCw
         w/dRTBPGL1wZrBI9PgHA7NFs+PBhMs//n4a82Az6ys21JElG00IMpCfF3cpV2Kcg2Zwd
         yPzYWep75zostsRHtzIswF2biC9xkUegg5VYCsVxzJZM1XJVqJyPMqIIK2YIGETRPL3D
         +yaVUVQmg9Msn8VEkpQmXUGWZADfklJEAKLTk+A7m7OpQRp7pJ107ZZjZfkKNGA5/ZKC
         Eo7w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@mailbox.org header.s=mail20150812 header.b=kiqjLJJr;
       dkim=pass header.i=@mailbox.org header.s=mail20150812 header.b=Y4b61l7C;
       spf=pass (google.com: domain of jrf@mailbox.org designates 80.241.60.212 as permitted sender) smtp.mailfrom=jrf@mailbox.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mailbox.org
Received: from mx1.mailbox.org (mx1.mailbox.org. [80.241.60.212])
        by mx.google.com with ESMTPS id t1si5326429ejl.9.2019.04.03.03.04.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Apr 2019 03:04:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrf@mailbox.org designates 80.241.60.212 as permitted sender) client-ip=80.241.60.212;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@mailbox.org header.s=mail20150812 header.b=kiqjLJJr;
       dkim=pass header.i=@mailbox.org header.s=mail20150812 header.b=Y4b61l7C;
       spf=pass (google.com: domain of jrf@mailbox.org designates 80.241.60.212 as permitted sender) smtp.mailfrom=jrf@mailbox.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mailbox.org
Received: from smtp2.mailbox.org (smtp2.mailbox.org [IPv6:2001:67c:2050:105:465:1:2:0])
	(using TLSv1.2 with cipher ECDHE-RSA-CHACHA20-POLY1305 (256/256 bits))
	(No client certificate requested)
	by mx1.mailbox.org (Postfix) with ESMTPS id 6E6294C0B3;
	Wed,  3 Apr 2019 12:04:11 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=mailbox.org; h=
	content-type:content-type:in-reply-to:mime-version:date:date
	:message-id:from:from:references:subject:subject:received; s=
	mail20150812; t=1554285846; bh=g8lWWSj8jGQO1LjFI3BiqOqC17IJkNx/K
	SewF2Hn2HU=; b=kiqjLJJrMHcK5WuFz1j4TvB1XjBrpDJaNKjxIhDHjhFsRo32q
	E+7TEz4IQnWrg6B3RFsgZ216qVOIqquNXcCP43tVw+7mH1DT1hKck+r4hUvwb20W
	et522LKwSXGgL960F+bEyFHzkTg4TmJnWECwm3gI2b27ED0WF3qmBlWQXqXByqkx
	Oe6g+zU1d4jrhBZsML4WeJJCm616m7QhkFbxxF+ftOd3i/FcOhqNYRCGzFxz1z5W
	829svqTJQWAhKshmY5n8BpyM5cUKLxjwQHqsmjKbVmDV6IfvXCp8tCIVa1rx3pLI
	UXiIXlgcV1ihKg8DsbCn5P7bsbGBI+ZY0EOdQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=mailbox.org; s=mail20150812;
	t=1554285849; h=from:from:sender:reply-to:subject:subject:date:date:
	 message-id:message-id:to:to:cc:cc:mime-version:mime-version:
	 content-type:content-type:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=R9Q6QIVKc468781lbTx4PhwohQZ4v5n+95uMustBFJo=;
	b=Y4b61l7CVgxlrWZkWAzqO3NmMy9gHC22voUz6jLovRgcoAjr8jcEVejOBo5ngDQfBuuwPl
	fv8PfBZPxrCAOYiTqS8+AQRFs7S51g8LnAPgutUmSsm1Hve7N0ZE47lr9zzSM50cn1k6tc
	LClLvdMCcGC1XBZTcaiehoPhflj3Fzw9V3Us8njeoetj0doGbKBD6+IKLQvBzjSeSR3IMX
	UB8SOHTzj9MRe55I0Piv6IAGfCzEltsyLHBqUbbnnicWaCCT9b5ae/joA9GYiwfZz9RdRu
	AX4v4JtYGh15Rm1hNHfbLvxJKoKWMo4Gyh75YT9f4GhY+3OUWdrkG0v765Z00A==
X-Virus-Scanned: amavisd-new at heinlein-support.de
Received: from smtp2.mailbox.org ([80.241.60.241])
	by spamfilter04.heinlein-hosting.de (spamfilter04.heinlein-hosting.de [80.241.56.122]) (amavisd-new, port 10030)
	with ESMTP id HRlIe-F8PL8e; Wed,  3 Apr 2019 12:04:06 +0200 (CEST)
Subject: Re: [Bug 75101] New: [bisected] s2disk / hibernate blocks on "Saving
 506031 image data pages () ..."
To: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
 Johannes Weiner <hannes@cmpxchg.org>, =?UTF-8?Q?Rodolfo_Garc=c3=ada_Pe?=
 =?UTF-8?B?w7FhcyAoa2l4KQ==?= <kix@kix.es>,
 Oliver Winker <oliverml1@oli1170.net>, bugzilla-daemon@bugzilla.kernel.org,
 linux-mm@kvack.org, Maxim Patlasov <mpatlasov@parallels.com>,
 Fengguang Wu <fengguang.wu@intel.com>, Tejun Heo <tj@kernel.org>,
 "Rafael J. Wysocki" <rjw@rjwysocki.net>, killian.de.volder@megasoft.be,
 atillakaraca72@hotmail.com, matheusfillipeag@gmail.com
References: <20140505233358.GC19914@cmpxchg.org> <5368227D.7060302@intel.com>
 <20140612220200.GA25344@cmpxchg.org> <539A3CD7.6080100@intel.com>
 <20140613045557.GL2878@cmpxchg.org> <539F1B66.2020006@intel.com>
 <20190402162500.def729ec05e6e267bff8a5da@linux-foundation.org>
 <20190403093432.GD8836@quack2.suse.cz>
From: Rainer Fiebig <jrf@mailbox.org>
Openpgp: preference=signencrypt
Autocrypt: addr=jrf@mailbox.org; prefer-encrypt=mutual; keydata=
 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
 SJBEfJI=
Message-ID: <1ea9f923-4756-85b2-6092-6d9e94d576a1@mailbox.org>
Date: Wed, 3 Apr 2019 12:04:15 +0200
MIME-Version: 1.0
In-Reply-To: <20190403093432.GD8836@quack2.suse.cz>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="0g7MVjGPB0q6pErxeKNcRBEuzPSBgX3O9"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--0g7MVjGPB0q6pErxeKNcRBEuzPSBgX3O9
Content-Type: multipart/mixed; boundary="ziNqwiAGm7g1A0TfTQlx1NbCEROspu74p";
 protected-headers="v1"
From: Rainer Fiebig <jrf@mailbox.org>
To: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
 Johannes Weiner <hannes@cmpxchg.org>, =?UTF-8?Q?Rodolfo_Garc=c3=ada_Pe?=
 =?UTF-8?B?w7FhcyAoa2l4KQ==?= <kix@kix.es>,
 Oliver Winker <oliverml1@oli1170.net>, bugzilla-daemon@bugzilla.kernel.org,
 linux-mm@kvack.org, Maxim Patlasov <mpatlasov@parallels.com>,
 Fengguang Wu <fengguang.wu@intel.com>, Tejun Heo <tj@kernel.org>,
 "Rafael J. Wysocki" <rjw@rjwysocki.net>, killian.de.volder@megasoft.be,
 atillakaraca72@hotmail.com, matheusfillipeag@gmail.com
Message-ID: <1ea9f923-4756-85b2-6092-6d9e94d576a1@mailbox.org>
Subject: Re: [Bug 75101] New: [bisected] s2disk / hibernate blocks on "Saving
 506031 image data pages () ..."
References: <20140505233358.GC19914@cmpxchg.org> <5368227D.7060302@intel.com>
 <20140612220200.GA25344@cmpxchg.org> <539A3CD7.6080100@intel.com>
 <20140613045557.GL2878@cmpxchg.org> <539F1B66.2020006@intel.com>
 <20190402162500.def729ec05e6e267bff8a5da@linux-foundation.org>
 <20190403093432.GD8836@quack2.suse.cz>
In-Reply-To: <20190403093432.GD8836@quack2.suse.cz>

--ziNqwiAGm7g1A0TfTQlx1NbCEROspu74p
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Am 03.04.19 um 11:34 schrieb Jan Kara:
> On Tue 02-04-19 16:25:00, Andrew Morton wrote:
>>
>> I cc'ed a bunch of people from bugzilla.
>>
>> Folks, please please please remember to reply via emailed
>> reply-to-all.  Don't use the bugzilla interface!
>>
>> On Mon, 16 Jun 2014 18:29:26 +0200 "Rafael J. Wysocki" <rafael.j.wysoc=
ki@intel.com> wrote:
>>
>>> On 6/13/2014 6:55 AM, Johannes Weiner wrote:
>>>> On Fri, Jun 13, 2014 at 01:50:47AM +0200, Rafael J. Wysocki wrote:
>>>>> On 6/13/2014 12:02 AM, Johannes Weiner wrote:
>>>>>> On Tue, May 06, 2014 at 01:45:01AM +0200, Rafael J. Wysocki wrote:=

>>>>>>> On 5/6/2014 1:33 AM, Johannes Weiner wrote:
>>>>>>>> Hi Oliver,
>>>>>>>>
>>>>>>>> On Mon, May 05, 2014 at 11:00:13PM +0200, Oliver Winker wrote:
>>>>>>>>> Hello,
>>>>>>>>>
>>>>>>>>> 1) Attached a full function-trace log + other SysRq outputs, se=
e [1]
>>>>>>>>> attached.
>>>>>>>>>
>>>>>>>>> I saw bdi_...() calls in the s2disk paths, but didn't check in =
detail
>>>>>>>>> Probably more efficient when one of you guys looks directly.
>>>>>>>> Thanks, this looks interesting.  balance_dirty_pages() wakes up =
the
>>>>>>>> bdi_wq workqueue as it should:
>>>>>>>>
>>>>>>>> [  249.148009]   s2disk-3327    2.... 48550413us : global_dirty_=
limits <-balance_dirty_pages_ratelimited
>>>>>>>> [  249.148009]   s2disk-3327    2.... 48550414us : global_dirtya=
ble_memory <-global_dirty_limits
>>>>>>>> [  249.148009]   s2disk-3327    2.... 48550414us : writeback_in_=
progress <-balance_dirty_pages_ratelimited
>>>>>>>> [  249.148009]   s2disk-3327    2.... 48550414us : bdi_start_bac=
kground_writeback <-balance_dirty_pages_ratelimited
>>>>>>>> [  249.148009]   s2disk-3327    2.... 48550414us : mod_delayed_w=
ork_on <-balance_dirty_pages_ratelimited
>>>>>>>> but the worker wakeup doesn't actually do anything:
>>>>>>>> [  249.148009] kworker/-3466    2d... 48550431us : finish_task_s=
witch <-__schedule
>>>>>>>> [  249.148009] kworker/-3466    2.... 48550431us : _raw_spin_loc=
k_irq <-worker_thread
>>>>>>>> [  249.148009] kworker/-3466    2d... 48550431us : need_to_creat=
e_worker <-worker_thread
>>>>>>>> [  249.148009] kworker/-3466    2d... 48550432us : worker_enter_=
idle <-worker_thread
>>>>>>>> [  249.148009] kworker/-3466    2d... 48550432us : too_many_work=
ers <-worker_enter_idle
>>>>>>>> [  249.148009] kworker/-3466    2.... 48550432us : schedule <-wo=
rker_thread
>>>>>>>> [  249.148009] kworker/-3466    2.... 48550432us : __schedule <-=
worker_thread
>>>>>>>>
>>>>>>>> My suspicion is that this fails because the bdi_wq is frozen at =
this
>>>>>>>> point and so the flush work never runs until resume, whereas bef=
ore my
>>>>>>>> patch the effective dirty limit was high enough so that image co=
uld be
>>>>>>>> written in one go without being throttled; followed by an fsync(=
) that
>>>>>>>> then writes the pages in the context of the unfrozen s2disk.
>>>>>>>>
>>>>>>>> Does this make sense?  Rafael?  Tejun?
>>>>>>> Well, it does seem to make sense to me.
>>>>>>  From what I see, this is a deadlock in the userspace suspend mode=
l and
>>>>>> just happened to work by chance in the past.
>>>>> Well, it had been working for quite a while, so it was a rather lar=
ge
>>>>> opportunity
>>>>> window it seems. :-)
>>>> No doubt about that, and I feel bad that it broke.  But it's still a=

>>>> deadlock that can't reasonably be accommodated from dirty throttling=
=2E
>>>>
>>>> It can't just put the flushers to sleep and then issue a large amoun=
t
>>>> of buffered IO, hoping it doesn't hit the dirty limits.  Don't shoot=

>>>> the messenger, this bug needs to be addressed, not get papered over.=

>>>>
>>>>>> Can we patch suspend-utils as follows?
>>>>> Perhaps we can.  Let's ask the new maintainer.
>>>>>
>>>>> Rodolfo, do you think you can apply the patch below to suspend-util=
s?
>>>>>
>>>>>> Alternatively, suspend-utils
>>>>>> could clear the dirty limits before it starts writing and restore =
them
>>>>>> post-resume.
>>>>> That (and the patch too) doesn't seem to address the problem with e=
xisting
>>>>> suspend-utils
>>>>> binaries, however.
>>>> It's userspace that freezes the system before issuing buffered IO, s=
o
>>>> my conclusion was that the bug is in there.  This is arguable.  I al=
so
>>>> wouldn't be opposed to a patch that sets the dirty limits to infinit=
y
>>>> from the ioctl that freezes the system or creates the image.
>>>
>>> OK, that sounds like a workable plan.
>>>
>>> How do I set those limits to infinity?
>>
>> Five years have passed and people are still hitting this.
>>
>> Killian described the workaround in comment 14 at
>> https://bugzilla.kernel.org/show_bug.cgi?id=3D75101.
>>
>> People can use this workaround manually by hand or in scripts.  But we=

>> really should find a proper solution.  Maybe special-case the freezing=

>> of the flusher threads until all the writeout has completed.  Or
>> something else.
>=20
> I've refreshed my memory wrt this bug and I believe the bug is really o=
n
> the side of suspend-utils (uswsusp or however it is called). They are l=
ow
> level system tools, they ask the kernel to freeze all processes
> (SNAPSHOT_FREEZE ioctl), and then they rely on buffered writeback (whic=
h is
> relatively heavyweight infrastructure) to work. That is wrong in my
> opinion.
>=20
> I can see Johanness was suggesting in comment 11 to use O_SYNC in
> suspend-utils which worked but was too slow. Indeed O_SYNC is rather bi=
g
> hammer but using O_DIRECT should be what they need and get better
> performance - no additional buffering in the kernel, no dirty throttlin=
g,
> etc. They only need their buffer & device offsets sector aligned - they=

> seem to be even page aligned in suspend-utils so they should be fine. A=
nd
> if the performance still sucks (currently they appear to do mostly rand=
om
> 4k writes so it probably would for rotating disks), they could use AIO =
DIO
> to get multiple pages in flight (as many as they dare to allocate buffe=
rs)
> and then the IO scheduler will reorder things as good as it can and the=
y
> should get reasonable performance.
>=20
> Is there someone who works on suspend-utils these days? Because the rep=
o
> I've found on kernel.org seems to be long dead (last commit in 2012).
>=20
> 								Honza
>=20

Whether it's suspend-utils (or uswsusp) or not could be answered quickly
by de-installing this package and using the kernel-methods instead.



--ziNqwiAGm7g1A0TfTQlx1NbCEROspu74p--

--0g7MVjGPB0q6pErxeKNcRBEuzPSBgX3O9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEE6yx5PjBNuGB2qJXG8OH3JiWK+PUFAlykhR8ACgkQ8OH3JiWK
+PVEVxAAweQpXkVxdYKz5KMcTu+5knrR7ZvucjRqXqNWqjNaakrHo8Yr6P1GL1Ji
Qauc7TjBojLxNvDpwiAgzg6CyqWAtB2q/jToBid2ViqLkKiUhFx56xC8v1cRdF2c
RnJ6pBYIqazfCALGsA1efDJ5XHczYKj5ngoF6oueRA25duqi1AK9kKr7oTefyvxU
4dn2OI8lmhv/+B1rLGJavzMzJ3dJd4va+M6rYdQKq2LqwzxX4ybkQL20nqv4NpwI
9L/3JJkLw1sH4M3q9s586O/z1RRpv1yrO5iC2PTVFOnwgnvoN6p7Nk6L3gWBcEbm
n1UEsloa6ILi9nz8QFrrZnY9qdl3nBcF7UrFka4dEOjI/qFPi4PFq2xXmVttgCfK
1MtoIHF4ek7cUHF1lDJd/N4ifk7zsEZhFaCyg4ZtEmEf0dQC7gDNPb8+Z86a3/rq
cMrcJg3VKtKQUVWY05KSulZZAwd3sSrARFRKvsAaHJ9wMPjAAO92YVElgjiJy5i9
wor+RMSeoza6PAJuBuwN+jJcZ5/eTP2reTO2I8Lyu35rrxNKpeLLfWP2O5NQyeb/
lXI3pjmXxludC9DSccIP21r/pgWbOLtzIjrIIuTvvyBG68mWPEAqIi2SW5cgCYLj
SSwv6f2Vd4FC112JTK+ECvtUyQ27s5ptuwk29WL6H+vp8OOEh+A=
=Mx4s
-----END PGP SIGNATURE-----

--0g7MVjGPB0q6pErxeKNcRBEuzPSBgX3O9--

