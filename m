Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 230C4C31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 16:26:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE7092054F
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 16:26:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE7092054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79E828E0008; Tue, 18 Jun 2019 12:26:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 728448E0001; Tue, 18 Jun 2019 12:26:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EFD28E0008; Tue, 18 Jun 2019 12:26:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3BEC78E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 12:26:17 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id c207so12729887qkb.11
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 09:26:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=NfNC7f7eajswdFM9CV/+wbfCmAEnJPucSb43bUoYHa0=;
        b=MU924Y7D7jBxEU544yo+3ouvvqTcfYSLGEz5Ym1/OeQLHfccJRElEyIRJ3dGxfolD1
         aOFmAIhtBcjnlAac12wYYQ8uxXluN9SYk2tTK8iB8dILISzcMkaNqhfzXJkUbMHOUtvG
         KF3dQypK8NHScs1TElGv34v2363C8XRydP0Vvosy+wYb4zlMhVIXYjpUVb0bI1zgHfUG
         4UJv0jEkOpb0TvhLhC/Djf0PtnodpKb7rUejCBgWxR/fvyN1kNWSMfQph/jJLGfWOHrh
         Lv0jdn45D0tiqjpT7N7Xp6VMxVhXmqnTwjDEnnoFhDnimd6EWlPdCepi+SmOEKxvccU6
         yYAg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAURZiEZ0qJcl/pRs1NpZyUelrBYRI+9fmnUsbYrg0Y/debx5X/s
	jnrVh8ZToMFASuKAkoNd9oYyFqml+Wm9LwQS9cDDOVAgdjLB5wr6FWlhhYoGDZlrVBMfAfMjKvX
	/nudbHmbHERYXASPA0U1TE0oY6pq+pjblUd1kAQsh9rSWiC+KvzlcT+Hfaz8yi1DVvQ==
X-Received: by 2002:a0c:d0f6:: with SMTP id b51mr6669730qvh.225.1560875177017;
        Tue, 18 Jun 2019 09:26:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIGDm0CstK1inZ/w9zyKrWhU5b3+l+QdCWehEXpjWxIdak3ZOM9Ugh8tLANUI8PWaEJhQ+
X-Received: by 2002:a0c:d0f6:: with SMTP id b51mr6669690qvh.225.1560875176520;
        Tue, 18 Jun 2019 09:26:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560875176; cv=none;
        d=google.com; s=arc-20160816;
        b=Dl94XQQdiz05kLcT6kz9Mj4H1/6TYc3dZtwWdqlvVdTaOd9BTepiilMh9D0oL8orAV
         AFsz6qHEll4Na7aJSDAWYDTe3UxPyue2WzNpMgN+RP3K4FNV0c51zMzs780yzToHob7v
         YXYr25cJaEiIwH/EcMOnQ8AbJrG3codwlASaGpt+ybYd3KbfgV16IvL/mB3bXXp88X8Q
         10Uv5JnYGVae7elcrGvpfuMJyej1bCRaLV5dCKE2t6Aj45IAzGx99kQUCBNq7Uh39Eju
         4y5h6O90w0F4i+k0WEYQlJ+v1WoHAnKwaNBwnFKIS51XnaRCp/MlUhglE1ZYwNTixL3O
         z/aA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=NfNC7f7eajswdFM9CV/+wbfCmAEnJPucSb43bUoYHa0=;
        b=TwM/fHFtT0d+2T1mh+rqvzt/Gep1u1vz8nDnICHKqUQlcSYWl2Ls96rA4qbgwDQzTn
         hZcYpUtJQktzRg2a2BMeYBRavcXpBjvM/8DNmid26r3Zr1ByZx/rOUMiRqVvYygfHuEF
         oI7FodUw/vYnpKfokC/8x/c6RaGjULu5x4bNoPC45wMH9899vmIOMCekxPCrVqhaNxgC
         3Jo/3TapnD0DalmGKJmkppbKcfv84koDeKQCScIOadF+nJXpXvblX7sci6KszP0mvkoI
         +ckw/Zvmwu8vfApXpEkt4Q1uHbmVg8c3jT4AeSDPMKi6atpFu6xOjaUOrwUKQ63Rkg/F
         NUNw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l124si3754027qkf.129.2019.06.18.09.26.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 09:26:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 087AF308A951;
	Tue, 18 Jun 2019 16:26:09 +0000 (UTC)
Received: from oldenburg2.str.redhat.com (ovpn-116-87.ams2.redhat.com [10.36.116.87])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 6F0C75F1B7;
	Tue, 18 Jun 2019 16:25:53 +0000 (UTC)
From: Florian Weimer <fweimer@redhat.com>
To: Dave Martin <Dave.Martin@arm.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>,  Peter Zijlstra
 <peterz@infradead.org>,  Thomas Gleixner <tglx@linutronix.de>,
  x86@kernel.org,  "H. Peter Anvin" <hpa@zytor.com>,  Ingo Molnar
 <mingo@redhat.com>,  linux-kernel@vger.kernel.org,
  linux-doc@vger.kernel.org,  linux-mm@kvack.org,
  linux-arch@vger.kernel.org,  linux-api@vger.kernel.org,  Arnd Bergmann
 <arnd@arndb.de>,  Andy Lutomirski <luto@amacapital.net>,  Balbir Singh
 <bsingharora@gmail.com>,  Borislav Petkov <bp@alien8.de>,  Cyrill Gorcunov
 <gorcunov@gmail.com>,  Dave Hansen <dave.hansen@linux.intel.com>,  Eugene
 Syromiatnikov <esyr@redhat.com>,  "H.J. Lu" <hjl.tools@gmail.com>,  Jann
 Horn <jannh@google.com>,  Jonathan Corbet <corbet@lwn.net>,  Kees Cook
 <keescook@chromium.org>,  Mike Kravetz <mike.kravetz@oracle.com>,  Nadav
 Amit <nadav.amit@gmail.com>,  Oleg Nesterov <oleg@redhat.com>,  Pavel
 Machek <pavel@ucw.cz>,  Randy Dunlap <rdunlap@infradead.org>,  "Ravi V.
 Shankar" <ravi.v.shankar@intel.com>,  Vedvyas Shanbhogue
 <vedvyas.shanbhogue@intel.com>
Subject: Re: [PATCH v7 22/27] binfmt_elf: Extract .note.gnu.property from an ELF file
References: <20190618091248.GB2790@e103592.cambridge.arm.com>
	<20190618124122.GH3419@hirez.programming.kicks-ass.net>
	<87ef3r9i2j.fsf@oldenburg2.str.redhat.com>
	<20190618125512.GJ3419@hirez.programming.kicks-ass.net>
	<20190618133223.GD2790@e103592.cambridge.arm.com>
	<d54fe81be77b9edd8578a6d208c72cd7c0b8c1dd.camel@intel.com>
	<87pnna7v1d.fsf@oldenburg2.str.redhat.com>
	<1ca57aaae8a2121731f2dcb1a137b92eed39a0d2.camel@intel.com>
	<87blyu7ubf.fsf@oldenburg2.str.redhat.com>
	<b0491cb517ba377da6496fe91a98fdbfca4609a9.camel@intel.com>
	<20190618162005.GF2790@e103592.cambridge.arm.com>
Date: Tue, 18 Jun 2019 18:25:51 +0200
In-Reply-To: <20190618162005.GF2790@e103592.cambridge.arm.com> (Dave Martin's
	message of "Tue, 18 Jun 2019 17:20:07 +0100")
Message-ID: <8736k67tdc.fsf@oldenburg2.str.redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.2 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Tue, 18 Jun 2019 16:26:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

* Dave Martin:

> On Tue, Jun 18, 2019 at 09:00:35AM -0700, Yu-cheng Yu wrote:
>> On Tue, 2019-06-18 at 18:05 +0200, Florian Weimer wrote:
>> > * Yu-cheng Yu:
>> > 
>> > > > I assumed that it would also parse the main executable and make
>> > > > adjustments based on that.
>> > > 
>> > > Yes, Linux also looks at the main executable's header, but not its
>> > > NT_GNU_PROPERTY_TYPE_0 if there is a loader.
>> > > 
>> > > > 
>> > > > ld.so can certainly provide whatever the kernel needs.  We need to tweak
>> > > > the existing loader anyway.
>> > > > 
>> > > > No valid statically-linked binaries exist today, so this is not a
>> > > > consideration at this point.
>> > > 
>> > > So from kernel, we look at only PT_GNU_PROPERTY?
>> > 
>> > If you don't parse notes/segments in the executable for CET, then yes.
>> > We can put PT_GNU_PROPERTY into the loader.
>> 
>> Thanks!
>
> Would this require the kernel and ld.so to be updated in a particular
> order to avoid breakage?  I don't know enough about RHEL to know how
> controversial that might be.

There is no official ld.so that will work with the current userspace
interface (in this patch submission).  Upstream glibc needs to be
updated anyway, so yet another change isn't much of an issue.  This is
not a problem; we knew that something like this might happen.

Sure, people need a new binutils with backports for PT_GNU_PROPERTY, but
given that only very few people will build CET binaries with older
binutils, I think that's not a real issue either.

Thanks,
Florian

