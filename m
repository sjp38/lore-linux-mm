Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 1B7FB6B002B
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 13:13:50 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id u3so1363227wey.14
        for <linux-mm@kvack.org>; Thu, 11 Oct 2012 10:13:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAKMH-YhMKO3XAN_G8MByTFK1OKQW=aNaEQsajja3-pYZDuczog@mail.gmail.com>
References: <CAKMH-Yhdxfq50fKR3TF8gc6i7JeAowD+Oc+dqpXOYvqiNiw=Vw@mail.gmail.com>
	<alpine.LSU.2.00.1210061344180.28972@eggly.anvils>
	<CAKMH-Ygp6mTtpt66cOj_wh5eicTgiH9bK9J=KPQfThTzU7-OLA@mail.gmail.com>
	<alpine.LSU.2.00.1210071641150.8431@eggly.anvils>
	<CAKMH-YhMKO3XAN_G8MByTFK1OKQW=aNaEQsajja3-pYZDuczog@mail.gmail.com>
Date: Thu, 11 Oct 2012 20:43:48 +0330
Message-ID: <CAKMH-YjFfN1DDkkDw1g-aoaC+wdMvXpdaiOOE9+Ef4AiF+veuA@mail.gmail.com>
Subject: PROBLEM: It seems that /usr/bin/time program reports a wrong value
 for MaxRSS.
From: Kamran Amini <kamran.amini.eng@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org

On Mon, Oct 8, 2012 at 3:43 AM, Hugh Dickins <hughd@google.com> wrote:
> On Sun, 7 Oct 2012, Kamran Amini wrote:
>> On Sun, Oct 7, 2012 at 1:18 AM, Hugh Dickins <hughd@google.com> wrote:
>> > On Thu, 4 Oct 2012, Kamran Amini wrote:
>> >>
>> >> It seems that /usr/bin/time program reports a wrong value for MaxRSS.
>> >> The report shows MaxRSS, about 4 times the
>> >> actual allocated memory by a process and its children. MaxRSS (Maximum
>> >> Resident Set Size) is assumed to be maximum
>> >> allocated memory by a process and its children. This bug report talks
>> >> about this problem. More descriptions are provided in
>> >> time-problem.tar.gz file attached to this mail.
>> >
>> > You are right.
>> >
>> > Well, time-problem.tar.gz goes into more detail than I had time
>> > to read, so I cannot promise that everything you say is right.
>> >
>> > But you're right that /usr/bin/time is reporting MaxRSS 4 times too much
>> > on x86, and many other architectures.  It expects rusage.ru_maxrss to be
>> > a count of pages, so mistakenly uses to ptok() upon it; whereas the Linux
>> > kernel supplies that number already in kilobytes (as "man 2 getrusage"
>> > makes clear).
>> >
>> > I see this was mentioned when 2.6.32's commit 1f10206cf8e9 "getrusage:
>> > fill ru_maxrss value" started putting the number there instead of zero:
>> >
>> >     Make ->ru_maxrss value in struct rusage filled accordingly to rss hiwater
>> >     mark.  This struct is filled as a parameter to getrusage syscall.
>> >     ->ru_maxrss value is set to KBs which is the way it is done in BSD
>> >     systems.  /usr/bin/time (gnu time) application converts ->ru_maxrss to KBs
>> >     which seems to be incorrect behavior.  Maintainer of this util was
>> >     notified by me with the patch which corrects it and cc'ed.
>> >
>> > It looks as if we were naive to expect a change in /usr/bin/time then:
>> > so far as I can see, time has stood still at time-1.7 ever since 1996.
>> > Its README does say:
>> >
>> >     Mail suggestions and bug reports for GNU time to
>> >     bug-gnu-utils@prep.ai.mit.edu.  Please include the version of
>> >     `time', which you can get by running `time --version', and the
>> >     operating system and C compiler you used.
>> >
>> > Please do so, if you have a chance, or let me know if you cannot and
>> > I'll do so: though I suspect the mail address is out-of-date by now,
>> > and that it should say bug-gnu-utils@gnu.org.
>> >
>> > You might also like to raise a bug with the distros you care about:
>> > maybe some already apply their own fix, or will do before time-1.8.
>> >
>> > But it does look as if you're the first in three years to notice and
>> > care!  So don't be surprised if it's not a high priority for anyone.
>> >
>> > And I don't think you need attach a .tar.gz: just explain in a few
>> > lines that Linux 2.6.32 and later fill ru_maxrss, but in kilobytes
>> > not pages: so /usr/bin/time displays 4 times the right number when
>> > it multiplies that up with ptok().  (I don't have a BSD system to
>> > confirm whether it's indeed wrong for BSD too.)
>> >
>> > Thanks,
>> > Hugh
>>
>> Thanks for the reply.
>>
>> I'm sorry.
>> I should have mentioned more details in my last email and I should
>
> Please don't drown me in so many words, we don't need more details!
>
>> have changed my subject to "It seems that wait4() system call fills
>> rusage.ru_maxrss with wrong value".
>>
>> Actually, we have read time's source code and there is no bug in it.
>
> Not necessarily a bug, but line 395 of time-1.7/time.c says
>               fprintf (fp, "%lu", ptok ((UL) resp->ru.ru_maxrss));
> and the comment on ptok (pages) has already mentioned that
>    Note: Some machines express getrusage statistics in terms of K,
>    others in terms of pages.  */
>
>> The time uses wait4() system call and  k_getrusage() function in
>> kernel/sys.c, line 1765  makes that 4 coefficient.
>>
>>        r->ru_maxrss = maxrss * (PAGE_SIZE / 1024); /* convert pages to KBs */
>>
>>     Comment says that this operation will convert the maxrss into KBs.
>>     But we think it has been converted to KBs previously.
>
> It has not been converted to KBs previously; but /usr/bin/time
> mistakenly "converts it to KBs" a second time afterwards.
>
> The Linux kernel has chosen to report ru_maxrss in KBs, following BSD.
> I have not loaded up a BSD system to check, but I have now checked the
> FreeBSD getrusage(2) manpage online, and indeed that documents ru_maxrss
> as in kilobytes.
>
> So when Jiri Pirko made Linux kernel 2.6.32 fill ru_maxrss with
> something better than 0, he chose to follow BSD by doing it in KBs
> (a better, more portable, unit than number of pages anyway); and
> simultaneously alerted the time-1.7 maintainer (he doesn't mention
> who, and I didn't actually see the name in his mail's Cc list) that
> the BSD value was already shown wrongly, and the Linux value about
> to be shown wrongly.  He and we thought it easier to keep BSD and
> Linux in synch, but no fix to the time package has appeared.
>
> Hugh

Hi again and sorry for late response.
You are absolutely right.

> Not necessarily a bug, but line 395 of time-1.7/time.c says
>               fprintf (fp, "%lu", ptok ((UL) resp->ru.ru_maxrss));
> and the comment on ptok (pages) has already mentioned that
>    Note: Some machines express getrusage statistics in terms of K,
>    others in terms of pages.  */

Yes, we have missed this portion of code. We checked codes right after
wait4() system call and we saw that no changes have been  made to
values read from kernel. We should be more careful :-). I removed ptok
function call from this line and compiled the code again. Everything
seemed right.

By the way, thank you for your time. As you said before, we should
raise a bug report for time project. I feel it can be a bug on some
architectures but not a huge bug. We will work on it.

Thank you Hugh

Kam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
