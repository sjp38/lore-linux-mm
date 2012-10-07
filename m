Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 950B66B005A
	for <linux-mm@kvack.org>; Sun,  7 Oct 2012 02:31:17 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id dq12so2357211wgb.26
        for <linux-mm@kvack.org>; Sat, 06 Oct 2012 23:31:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1210061344180.28972@eggly.anvils>
References: <CAKMH-Yhdxfq50fKR3TF8gc6i7JeAowD+Oc+dqpXOYvqiNiw=Vw@mail.gmail.com>
	<alpine.LSU.2.00.1210061344180.28972@eggly.anvils>
Date: Sun, 7 Oct 2012 10:01:15 +0330
Message-ID: <CAKMH-Ygp6mTtpt66cOj_wh5eicTgiH9bK9J=KPQfThTzU7-OLA@mail.gmail.com>
Subject: Re: PROBLEM: It seems that /usr/bin/time program reports a wrong
 value for MaxRSS.
From: Kamran Amini <kamran.amini.eng@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Behnam Momeni <s.b.momeni@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Oct 7, 2012 at 1:18 AM, Hugh Dickins <hughd@google.com> wrote:
> On Thu, 4 Oct 2012, Kamran Amini wrote:
>>
>> It seems that /usr/bin/time program reports a wrong value for MaxRSS.
>> The report shows MaxRSS, about 4 times the
>> actual allocated memory by a process and its children. MaxRSS (Maximum
>> Resident Set Size) is assumed to be maximum
>> allocated memory by a process and its children. This bug report talks
>> about this problem. More descriptions are provided in
>> time-problem.tar.gz file attached to this mail.
>
> You are right.
>
> Well, time-problem.tar.gz goes into more detail than I had time
> to read, so I cannot promise that everything you say is right.
>
> But you're right that /usr/bin/time is reporting MaxRSS 4 times too much
> on x86, and many other architectures.  It expects rusage.ru_maxrss to be
> a count of pages, so mistakenly uses to ptok() upon it; whereas the Linux
> kernel supplies that number already in kilobytes (as "man 2 getrusage"
> makes clear).
>
> I see this was mentioned when 2.6.32's commit 1f10206cf8e9 "getrusage:
> fill ru_maxrss value" started putting the number there instead of zero:
>
>     Make ->ru_maxrss value in struct rusage filled accordingly to rss hiwater
>     mark.  This struct is filled as a parameter to getrusage syscall.
>     ->ru_maxrss value is set to KBs which is the way it is done in BSD
>     systems.  /usr/bin/time (gnu time) application converts ->ru_maxrss to KBs
>     which seems to be incorrect behavior.  Maintainer of this util was
>     notified by me with the patch which corrects it and cc'ed.
>
> It looks as if we were naive to expect a change in /usr/bin/time then:
> so far as I can see, time has stood still at time-1.7 ever since 1996.
> Its README does say:
>
>     Mail suggestions and bug reports for GNU time to
>     bug-gnu-utils@prep.ai.mit.edu.  Please include the version of
>     `time', which you can get by running `time --version', and the
>     operating system and C compiler you used.
>
> Please do so, if you have a chance, or let me know if you cannot and
> I'll do so: though I suspect the mail address is out-of-date by now,
> and that it should say bug-gnu-utils@gnu.org.
>
> You might also like to raise a bug with the distros you care about:
> maybe some already apply their own fix, or will do before time-1.8.
>
> But it does look as if you're the first in three years to notice and
> care!  So don't be surprised if it's not a high priority for anyone.
>
> And I don't think you need attach a .tar.gz: just explain in a few
> lines that Linux 2.6.32 and later fill ru_maxrss, but in kilobytes
> not pages: so /usr/bin/time displays 4 times the right number when
> it multiplies that up with ptok().  (I don't have a BSD system to
> confirm whether it's indeed wrong for BSD too.)
>
> Thanks,
> Hugh

Thanks for the reply.

I'm sorry.
I should have mentioned more details in my last email and I should
have changed my subject to "It seems that wait4() system call fills
rusage.ru_maxrss with wrong value".

Actually, we have read time's source code and there is no bug in it.
The time uses wait4() system call and  k_getrusage() function in
kernel/sys.c, line 1765  makes that 4 coefficient.  Source code can
be found here :

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=blob;f=kernel/sys.c;h=c5cb5b99cb8152808f569f6b993010a33e646bce;hb=HEAD

This is full explanation. This can be found in time-problem.tar.gz
too. If you want, you can only read "README" section in below
description.

    In a project, we needed to measure maximum amount of memory
    used by a process and its children. In all measurements, memory
    allocated by a process differed dramatically with the value /usr/bin/time
    was showing. Even, values shown in 'top' and 'htop' tools differed a
    lot with that. So, we decided to write a simple C program allocating
    a specified amount of memory. We used this program to allocate,
    for example, 100MB. And all tools showed 100MB for the process
    except /usr/bin/time which showed about 400MB for MaxRSS attribute.

    We did more tests and we felt there should be a relationship between
    what /usr/bin/time was reporting and what we could find using 'top' and
    'htop'. A simple shell helped us a lot. We ran the C program many
    times to allocate different amounts of memory, from 1MB to 300MB
    and for each run, we saved the reported MaxRSS value by /usr/bin/time.
    Below you can find a sample result after executing the shell script from
    1MB to 20 MB amount of memory. Then, we calculated Regression
    Line Equation for the results and the outcome was very describing.

    Real allocated value (KB)    /usr/bin/time reported value (KB)
    -------------------------           ----------------------------------
           1024                                5568
           2048                                9664
           3072                                13744
           4096                                17856
           5120                                21936
           6144                                26048
           7168                                30144
           8192                                34224
           9216                                38336
           10240                               42416
           11264                               46528
           12288                               50624
           13312                               54704
           14336                               58816
           15360                               62912
           16384                               66992
           17408                               71088
           18432                               75184
           19456                               79280
           20480                               83376

    Regression line equation for above set is: y = 3.9994360902256x +
                                           1470.0631578947 =~ 4(x + 367.5)

    It is very interesting. For 20 processes made by the shell script,
    there is a portion of memory which is almost constant and a portion
    which is allocated from heap memory; the result is multiplied by 4.
    For more accurate results, we ran the shell from 1MB to 300MB.
    You can find the results in data.csv file. Also, you can use shell
    script "produce_data.sh" to regenerate the dataset. For our test,
    regression line equation is:  y = 3.9999924894999x +
                                                 1463.9307915273 =~ 4(x + 365.9)
    And again, it confirms our hypothesis about the reason why MaxRSS
    reports different values for maximum allocated memory. You can
    use 'http://www.alcula.com/calculators/statistics/linear-regression/'
    for regression line calculations.

README {
    For next step, we tracked down /usr/bin/time source code. It uses
    wait4() system call. We downloaded mainline kernel source code
    3.6. In file kernel/sys.c, at line 1765, maxrss variable is multiplied
    by the (PAGE_SIZE / 1024) factor. PAGE_SIZE is 4096 in x86
    architectures so (PAGE_SIZE / 1024) is 4. This is the line of code:

       r->ru_maxrss = maxrss * (PAGE_SIZE / 1024); /* convert pages to KBs */

    Comment says that this operation will convert the maxrss into KBs.
    But we think it has been converted to KBs previously. It may be a
    missed line of code after correcting maxrss unit to KBs. We also,
    checked 3.5.5 version source code which is current stable version.
    The line yet exists. Honestly, before tracking the source code, we
    thought that regression line equation should be something like
    4x + b equation. But after seeing the source code and this line, we
    got sure that our regression line equation should be 4(x + b).
}

Thanks
Kam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
