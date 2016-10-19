Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3E4076B025E
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 13:29:23 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id m193so8065433lfm.7
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 10:29:23 -0700 (PDT)
Received: from thejh.net (thejh.net. [37.221.195.125])
        by mx.google.com with ESMTPS id 99si4408214lfx.261.2016.10.19.10.29.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 10:29:21 -0700 (PDT)
Date: Wed, 19 Oct 2016 19:29:17 +0200
From: Jann Horn <jann@thejh.net>
Subject: Re: [REVIEW][PATCH] exec: Don't exec files the userns root can not
 read.
Message-ID: <20161019172917.GE1210@laptop.thejh.net>
References: <87twcbq696.fsf@x220.int.ebiederm.org>
 <20161018135031.GB13117@dhcp22.suse.cz>
 <8737jt903u.fsf@xmission.com>
 <20161018150507.GP14666@pc.thejh.net>
 <87twc9656s.fsf@xmission.com>
 <20161018191206.GA1210@laptop.thejh.net>
 <87r37dnz74.fsf@xmission.com>
 <87k2d5nytz.fsf_-_@xmission.com>
 <CALCETrU4SZYUEPrv4JkpUpA+0sZ=EirZRftRDp+a5hce5E7HgA@mail.gmail.com>
 <87y41kjn6l.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87y41kjn6l.fsf@xmission.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>

On Wed, Oct 19, 2016 at 11:52:50AM -0500, Eric W. Biederman wrote:
> Andy Lutomirski <luto@amacapital.net> writes:
> > Simply ptrace yourself, exec the
> > program, and then dump the program out.  A program that really wants
> > to be unreadable should have a stub: the stub is setuid and readable,
> > but all the stub does is to exec the real program, and the real
> > program should have mode 0500 or similar.
> >
> > ISTM the "right" check would be to enforce that the program's new
> > creds can read the program, but that will break backwards
> > compatibility.
> 
> Last I looked I had the impression that exec of a setuid program kills
> the ptrace.
> 
> If we are talking about a exec of a simple unreadable executable (aka
> something that sets undumpable but is not setuid or setgid).  Then I
> agree it should break the ptrace as well and since those programs are as
> rare as hens teeth I don't see any problem with changing the ptrace behavior
> in that case.

Nope. check_unsafe_exec() sets LSM_UNSAFE_* flags in bprm->unsafe, and then
the flags are checked by the LSMs and cap_bprm_set_creds() in commoncap.c.
cap_bprm_set_creds() just degrades the execution to a non-setuid-ish one,
and e.g. ptracers stay attached.

Same thing happens if the fs struct is shared with another process or if
NO_NEW_PRIVS is active.

(Actually, it's still a bit like normal setuid execution: IIRC AT_SECURE
stays active, and the resulting process still won't be dumpable, so it's
not possible for a *new* ptracer to attach afterwards. But this is just
from memory, I'm not entirely sure.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
