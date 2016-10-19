Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8E9536B0267
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 12:54:59 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e6so1349129pfk.2
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 09:54:59 -0700 (PDT)
Received: from out02.mta.xmission.com (out02.mta.xmission.com. [166.70.13.232])
        by mx.google.com with ESMTPS id a15si13235890pfa.272.2016.10.19.09.54.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 09:54:58 -0700 (PDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <87twcbq696.fsf@x220.int.ebiederm.org>
	<20161018135031.GB13117@dhcp22.suse.cz> <8737jt903u.fsf@xmission.com>
	<20161018150507.GP14666@pc.thejh.net> <87twc9656s.fsf@xmission.com>
	<20161018191206.GA1210@laptop.thejh.net> <87r37dnz74.fsf@xmission.com>
	<87k2d5nytz.fsf_-_@xmission.com>
	<CALCETrU4SZYUEPrv4JkpUpA+0sZ=EirZRftRDp+a5hce5E7HgA@mail.gmail.com>
Date: Wed, 19 Oct 2016 11:52:50 -0500
In-Reply-To: <CALCETrU4SZYUEPrv4JkpUpA+0sZ=EirZRftRDp+a5hce5E7HgA@mail.gmail.com>
	(Andy Lutomirski's message of "Wed, 19 Oct 2016 08:30:14 -0700")
Message-ID: <87y41kjn6l.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [REVIEW][PATCH] exec: Don't exec files the userns root can not read.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Jann Horn <jann@thejh.net>, Michal Hocko <mhocko@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>

Andy Lutomirski <luto@amacapital.net> writes:

> On Tue, Oct 18, 2016 at 2:15 PM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>>
>> When the user namespace support was merged the need to prevent
>> ptracing an executable that is not readable was overlooked.
>
> Before getting too excited about this fix, isn't there a much bigger
> hole that's been there forever?

In this case it was a newish hole (2011) that the user namespace support
added that I am closing.  I am not super excited but I figure it is
useful to make the kernel semantics at least as secure as they were
before.

> Simply ptrace yourself, exec the
> program, and then dump the program out.  A program that really wants
> to be unreadable should have a stub: the stub is setuid and readable,
> but all the stub does is to exec the real program, and the real
> program should have mode 0500 or similar.
>
> ISTM the "right" check would be to enforce that the program's new
> creds can read the program, but that will break backwards
> compatibility.

Last I looked I had the impression that exec of a setuid program kills
the ptrace.

If we are talking about a exec of a simple unreadable executable (aka
something that sets undumpable but is not setuid or setgid).  Then I
agree it should break the ptrace as well and since those programs are as
rare as hens teeth I don't see any problem with changing the ptrace behavior
in that case.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
