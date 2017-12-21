Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C1F8D6B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 03:56:38 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r63so3581945wmb.9
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 00:56:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u17sor10381169edf.7.2017.12.21.00.56.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Dec 2017 00:56:37 -0800 (PST)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <20171221080203.GZ4831@dhcp22.suse.cz>
References: <20171219094848.GE2787@dhcp22.suse.cz> <CAKgNAkjJrmCFY-h2oqKS3zM_D+Csx-17A27mh08WKahyOVzrgQ@mail.gmail.com>
 <20171220092025.GD4831@dhcp22.suse.cz> <CAKgNAkisD7zDRoqJd6Gk1JMCZ8+Huj5QPV04nh2JXHMA+_R0-A@mail.gmail.com>
 <20171221080203.GZ4831@dhcp22.suse.cz>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Thu, 21 Dec 2017 09:56:16 +0100
Message-ID: <CAKgNAkjSF9fXhKCxPMp92zftA4Qtq91WBt8L5UR50oQO8HgRxw@mail.gmail.com>
Subject: Re: shmctl(SHM_STAT) vs. /proc/sysvipc/shm permissions discrepancies
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linux API <linux-api@vger.kernel.org>, Manfred Spraul <manfred@colorfullife.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mike Waychison <mikew@google.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Michal,

On 21 December 2017 at 09:02, Michal Hocko <mhocko@kernel.org> wrote:
> On Wed 20-12-17 17:17:46, Michael Kerrisk wrote:
>> Hello Michal,
>>
>> On 20 December 2017 at 10:20, Michal Hocko <mhocko@kernel.org> wrote:
>> > On Tue 19-12-17 17:45:40, Michael Kerrisk wrote:
>> >> But, is
>> >> there a pressing reason to make the change? (Okay, I guess iterating
>> >> using *_STAT is nicer than parsing /proc/sysvipc/*.)
>> >
>> > The reporter of this issue claims that "Reading /proc/sysvipc/shm is way
>> > slower than executing the system call." I haven't checked that but I can
>> > imagine that /proc/sysvipc/shm can take quite some time when there are
>> > _many_ segments registered.
>>
>> Yes, that makes sense.
>>
>> > So they would like to use the syscall but
>> > the interacting parties do not have compatible permissions.
>>
>> So, I don't think there is any security issue, since the same info is
>> available in /proc/sysvipc/*.
>
> Well, I am not sure this is a valid argument (maybe I just misread your
> statement).

(Or perhaps I was not clear enough; see below)

> Our security model _might_ be broken because of the sysipc
> proc interface existance already. I am not saying it is broken because
> I cannot see an attack vector based solely on the metadata information
> knowledge. An attacker still cannot see/modify the real data. But maybe
> there are some bugs lurking there and knowing the metadata might help to
> exploit them. I dunno.
>
> You are certainly right that modifying/adding STAT flag to comply with
> the proc interface permission model will not make the system any more
> vulnerable, though.

Yep, that was my point. Modifying _STAT behavior won't decrease security.

That said, /proc/sysvipc/* has been around for a long time now, and
nothing bad seems to have happened so far, AFAIK.

>> The only question would be whether
>> change in the *_STAT behavior might surprise some applications into
>> behaving differently. I presume the chances of that are low, but if it
>> was a concert, one could add new shmctl/msgctl/semctl *_STAT_ALL (or
>> some such) operations that have the desired behavior.
>
> I would lean towards _STAT_ALL because this is Linux specific behavior
> (I have looked at what BSD does here and they are checking permissions
> for STAT as well). It would also be simpler to revert if we ever find
> that this is a leak with security consequences.

Oh -- I was unaware of this BSD behavior. At least on the various UNIX
systems that I ever used SYSVIPC (including one or two ancient
commercial BSD derivatives), ipcs(1) showed all IPC objects. (On
FeeBSD, at least, it looks like ipcs(1) doesn't use the *_STAT
interfaces.)

Cheers,

Michael



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
