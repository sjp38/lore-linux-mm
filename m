Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1A77C6B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 13:58:03 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id tz10so14670211pab.3
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 10:58:03 -0700 (PDT)
Received: from out01.mta.xmission.com (out01.mta.xmission.com. [166.70.13.231])
        by mx.google.com with ESMTPS id r85si24760843pfr.113.2016.10.19.10.58.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 10:58:02 -0700 (PDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <87twcbq696.fsf@x220.int.ebiederm.org>
	<20161018135031.GB13117@dhcp22.suse.cz> <8737jt903u.fsf@xmission.com>
	<20161018150507.GP14666@pc.thejh.net> <87twc9656s.fsf@xmission.com>
	<20161018191206.GA1210@laptop.thejh.net> <87r37dnz74.fsf@xmission.com>
	<87k2d5nytz.fsf_-_@xmission.com>
	<CALCETrU4SZYUEPrv4JkpUpA+0sZ=EirZRftRDp+a5hce5E7HgA@mail.gmail.com>
	<87y41kjn6l.fsf@xmission.com> <20161019172917.GE1210@laptop.thejh.net>
	<CALCETrWSY1SRse5oqSwZ=goQ+ZALd2XcTP3SZ8ry49C8rNd98Q@mail.gmail.com>
Date: Wed, 19 Oct 2016 12:55:53 -0500
In-Reply-To: <CALCETrWSY1SRse5oqSwZ=goQ+ZALd2XcTP3SZ8ry49C8rNd98Q@mail.gmail.com>
	(Andy Lutomirski's message of "Wed, 19 Oct 2016 10:32:39 -0700")
Message-ID: <87pomwi5p2.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [REVIEW][PATCH] exec: Don't exec files the userns root can not read.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Jann Horn <jann@thejh.net>, Michal Hocko <mhocko@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>

Andy Lutomirski <luto@amacapital.net> writes:

> On Wed, Oct 19, 2016 at 10:29 AM, Jann Horn <jann@thejh.net> wrote:
>> On Wed, Oct 19, 2016 at 11:52:50AM -0500, Eric W. Biederman wrote:
>>> Andy Lutomirski <luto@amacapital.net> writes:
>>> > Simply ptrace yourself, exec the
>>> > program, and then dump the program out.  A program that really wants
>>> > to be unreadable should have a stub: the stub is setuid and readable,
>>> > but all the stub does is to exec the real program, and the real
>>> > program should have mode 0500 or similar.
>>> >
>>> > ISTM the "right" check would be to enforce that the program's new
>>> > creds can read the program, but that will break backwards
>>> > compatibility.
>>>
>>> Last I looked I had the impression that exec of a setuid program kills
>>> the ptrace.
>>>
>>> If we are talking about a exec of a simple unreadable executable (aka
>>> something that sets undumpable but is not setuid or setgid).  Then I
>>> agree it should break the ptrace as well and since those programs are as
>>> rare as hens teeth I don't see any problem with changing the ptrace behavior
>>> in that case.
>>
>> Nope. check_unsafe_exec() sets LSM_UNSAFE_* flags in bprm->unsafe, and then
>> the flags are checked by the LSMs and cap_bprm_set_creds() in commoncap.c.
>> cap_bprm_set_creds() just degrades the execution to a non-setuid-ish one,
>> and e.g. ptracers stay attached.
>
> I think you're right.  I ought to be completely sure because I rewrote
> that code back in 2005 or so back when I thought kernel programming
> was only for the cool kids.  It was probably my first kernel patch
> ever and it closed an awkward-to-exploit root hole.  But it's been a
> while.  (Too bad my second (IIRC) kernel patch was more mundane and
> fixed the mute button on "new" Lenovo X60-era laptops and spend
> several years in limbo...)

Ah yes and this is only a problem if the ptracer does not have
CAP_SYS_PTRACE.

If the tracer does not have sufficient permissions any opinions on
failing the exec or kicking out the ptracer?  I am leaning towards failing
the exec as it is more obvious if someone cares.  Dropping the ptracer
could be a major mystery.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
