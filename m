Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 373E0280250
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 14:38:40 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id 9so61426483ywa.7
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 11:38:40 -0700 (PDT)
Received: from mail-vk0-x22a.google.com (mail-vk0-x22a.google.com. [2607:f8b0:400c:c05::22a])
        by mx.google.com with ESMTPS id c7si11669967ywf.377.2016.10.19.11.38.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 11:38:39 -0700 (PDT)
Received: by mail-vk0-x22a.google.com with SMTP id 83so38679238vkd.0
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 11:38:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87pomwi5p2.fsf@xmission.com>
References: <87twcbq696.fsf@x220.int.ebiederm.org> <20161018135031.GB13117@dhcp22.suse.cz>
 <8737jt903u.fsf@xmission.com> <20161018150507.GP14666@pc.thejh.net>
 <87twc9656s.fsf@xmission.com> <20161018191206.GA1210@laptop.thejh.net>
 <87r37dnz74.fsf@xmission.com> <87k2d5nytz.fsf_-_@xmission.com>
 <CALCETrU4SZYUEPrv4JkpUpA+0sZ=EirZRftRDp+a5hce5E7HgA@mail.gmail.com>
 <87y41kjn6l.fsf@xmission.com> <20161019172917.GE1210@laptop.thejh.net>
 <CALCETrWSY1SRse5oqSwZ=goQ+ZALd2XcTP3SZ8ry49C8rNd98Q@mail.gmail.com> <87pomwi5p2.fsf@xmission.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 19 Oct 2016 11:38:18 -0700
Message-ID: <CALCETrUz2oU6OYwQ9K4M-SUg6FeDsd6Q1gf1w-cJRGg2PdmK8g@mail.gmail.com>
Subject: Re: [REVIEW][PATCH] exec: Don't exec files the userns root can not read.
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Jann Horn <jann@thejh.net>, Michal Hocko <mhocko@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>

On Wed, Oct 19, 2016 at 10:55 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Andy Lutomirski <luto@amacapital.net> writes:
>
>> On Wed, Oct 19, 2016 at 10:29 AM, Jann Horn <jann@thejh.net> wrote:
>>> On Wed, Oct 19, 2016 at 11:52:50AM -0500, Eric W. Biederman wrote:
>>>> Andy Lutomirski <luto@amacapital.net> writes:
>>>> > Simply ptrace yourself, exec the
>>>> > program, and then dump the program out.  A program that really wants
>>>> > to be unreadable should have a stub: the stub is setuid and readable,
>>>> > but all the stub does is to exec the real program, and the real
>>>> > program should have mode 0500 or similar.
>>>> >
>>>> > ISTM the "right" check would be to enforce that the program's new
>>>> > creds can read the program, but that will break backwards
>>>> > compatibility.
>>>>
>>>> Last I looked I had the impression that exec of a setuid program kills
>>>> the ptrace.
>>>>
>>>> If we are talking about a exec of a simple unreadable executable (aka
>>>> something that sets undumpable but is not setuid or setgid).  Then I
>>>> agree it should break the ptrace as well and since those programs are as
>>>> rare as hens teeth I don't see any problem with changing the ptrace behavior
>>>> in that case.
>>>
>>> Nope. check_unsafe_exec() sets LSM_UNSAFE_* flags in bprm->unsafe, and then
>>> the flags are checked by the LSMs and cap_bprm_set_creds() in commoncap.c.
>>> cap_bprm_set_creds() just degrades the execution to a non-setuid-ish one,
>>> and e.g. ptracers stay attached.
>>
>> I think you're right.  I ought to be completely sure because I rewrote
>> that code back in 2005 or so back when I thought kernel programming
>> was only for the cool kids.  It was probably my first kernel patch
>> ever and it closed an awkward-to-exploit root hole.  But it's been a
>> while.  (Too bad my second (IIRC) kernel patch was more mundane and
>> fixed the mute button on "new" Lenovo X60-era laptops and spend
>> several years in limbo...)
>
> Ah yes and this is only a problem if the ptracer does not have
> CAP_SYS_PTRACE.
>
> If the tracer does not have sufficient permissions any opinions on
> failing the exec or kicking out the ptracer?  I am leaning towards failing
> the exec as it is more obvious if someone cares.  Dropping the ptracer
> could be a major mystery.

I would suggest leaving it alone.  Changing it could break enough
things that a sysctl would be needed, and I just don't see how this is
a significant issue, especially since it's been insecure forever.
Anyone who cares should do the stub executable trick:

/sbin/foo: 04755, literally just does execve("/sbin/foo-helper");

/sbin/foo-helper: 0500.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
