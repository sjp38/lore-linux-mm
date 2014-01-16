Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1A03B6B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 08:42:13 -0500 (EST)
Received: by mail-we0-f178.google.com with SMTP id t60so3127368wes.23
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 05:42:12 -0800 (PST)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id v4si5853680wjq.110.2014.01.16.05.42.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Jan 2014 05:42:12 -0800 (PST)
Received: by mail-wi0-f181.google.com with SMTP id hi8so2203014wib.14
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 05:42:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAFftDdpyXdgk7hUt4geKLER7s44bOieZ4ugpQXUKj5m0mVkdyg@mail.gmail.com>
References: <1389808934-4446-1-git-send-email-wroberts@tresys.com>
	<2002335.9x4iUKkcnh@x2>
	<CAFftDdqJbMwTDkYn6FbRE=j69F4mE+9i=Sw6aQTTs99hsP0KwA@mail.gmail.com>
	<3286317.e32vfzCzRe@x2>
	<CAFftDdpyXdgk7hUt4geKLER7s44bOieZ4ugpQXUKj5m0mVkdyg@mail.gmail.com>
Date: Thu, 16 Jan 2014 08:42:11 -0500
Message-ID: <CAFftDdqrpcgU1kCyrwCsDRHXhA182p38e6-CytsvPRTVYfi-zg@mail.gmail.com>
Subject: Re: [PATCH v3 3/3] audit: Audit proc cmdline value
From: William Roberts <bill.c.roberts@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Grubb <sgrubb@redhat.com>
Cc: "linux-audit@redhat.com" <linux-audit@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Richard Guy Briggs <rgb@redhat.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, akpm@linux-foundation.org, Stephen Smalley <sds@tycho.nsa.gov>, William Roberts <wroberts@tresys.com>

On Thu, Jan 16, 2014 at 8:40 AM, William Roberts
<bill.c.roberts@gmail.com> wrote:
> On Thu, Jan 16, 2014 at 7:11 AM, Steve Grubb <sgrubb@redhat.com> wrote:
>> On Thursday, January 16, 2014 07:03:34 AM William Roberts wrote:
>>> On Thu, Jan 16, 2014 at 6:02 AM, Steve Grubb <sgrubb@redhat.com> wrote:
>>> > On Wednesday, January 15, 2014 09:08:39 PM William Roberts wrote:
>>> >> >> > Try this,
>>> >> >> >
>>> >> >> > cp /bin/ls 'test test test'
>>> >> >> > auditctll -a always,exit -F arch=b64 -S stat -k test
>>> >> >> > ./test\ test\ test './test\ test\ test'
>>> >> >> > auditctl -D
>>> >> >> > ausearch --start recent --key test
>>> >> >> >
>>> >> >> >> On the event of weird chars, it gets hex escaped.
>>> >> >> >
>>> >> >> > and its all in 1 lump with no escaping to figure out what is what.
>>> >> >>
>>> >> >> Un-escape it. ausearch does this with paths. Then if you need to parse
>>> >> >> it, do it.
>>> >> >
>>> >> > How can you? When you unescape cmdline for the example I gave, you will
>>> >> > have "./test test test ./test test test".  Which program ran and how
>>> >> > many
>>> >> > arguments were passed? If we are trying to improve on what comm=
>>> >> > provides
>>> >> > by having the full information, I have to be able to find out exactly
>>> >> > what the program name was so it can be used for searching. If that
>>> >> > can't
>>> >> > be done, then we don't need this addition in its current form.
>>> >>
>>> >> In your example, you will have an execve record, with it parsed, will you
>>> >> not?
>>> >
>>> > Only if you change your patch.
>>>
>>> My patch has nothing to do with the emitting of an execve record. You
>>> will get an
>>> execve record with the arguments parsed out. Its not even really
>>> "parsing" as each
>>> element is in a NULL terminated char * array.
>>
>> That is what I am telling you is wrong. We can't have a string that can't be
>> parsed later. If you reformat the output as an execve record, then we have
>> something that is trustworthy.
>
Formatting of the string does not change the trust worthiness of its value. If
I told you your name was JoEy, I could re-type it like this Joey and
its still not
true. I think the part of this your confusing is that this is really
proctitle. On desktops
the execution environment simply takes all the cmdline args and dumps
it there. But,
this is not always the case. The reason your arguments and command are
well formatted
on exec is becuase of the interface to the kernel. Its in a char *
array. Their is NO parsing
that is done on the kernels behalf. Accessing each value is just a
matter of indexing the array.
Parsing "cmdline", which again is arbitrary and controlled via
setproctitle() is not needed,
because its arbitrary. However, the fact that its arbitrary does not
affect its usefulness. Many
values used in the audit records, like comm (prctl()), can be
manipulated by executing programs. But it
may help a user to deduce what is going on.

>>
>>
>>> >> cmdline does not necessarily represent the arguments or process name.
>>> >> Sometimes it does, sometimes it doesn't. Just treat the thing as one
>>> >> string, perhaps do some form of substring matching in a tool.
>>> >
>>> > You are missing the point. The point is that you are trying to place trust
>>> > in something that can be gamed. The audit system is designed such that it
>>> > cannot be fooled very easily. Each piece of the subject and object are
>>> > separated so that programs can be written to analyze events. What I am
>>> > trying to say is now you are making something that concatenates fields
>>> > with no way to regroup them later to reconstruct what really happened,
>>> >
>>> >> To make this clear, I am not trying to improve on what comm provides.
>>> >> comm provides
>>> >> 16 chars for per thread name. The key is, its per thread, and can be
>>> >> anything. The
>>> >> "cmdline" value, is an arbitrary spot that is a global entity for the
>>> >> process. So in my change, all things coming into these events will have a
>>> >> similar cmdline audit. Which may help in narrowing down on whats going on
>>> >> in the system
>>> >
>>> > It needs to be more trustworthy than this.
>>>
>>> Its as trustworthy as comm, its as trustworthy as path, etc. The audit
>>> subsystem already prints many
>>> untrusted values to aid in narrowing down the process, or to observe a
>>> running processes behavior; this
>>> is no different.
>>
>> Sure it is. comm is 1 entity on the value side of the name value pair. If it
>> is detected as being special, its encoded so that it can be correctly
>> dissected later. What you are creating cannot be correctly dissected. Please
>> try the example I gave you and think about it a bit.
>
Your example BTW, can be parsed. I have an FSM on my
whiteboard that will do it. But you don't need to parse it. Again,
as I stated above it might not be set to your example. If you have
a process that does this:

prctl(PR_SET_NAME, "./test \test \test");

You will see that comm now has white space and other chars.

I think to help avoid this confusion, I will change the keyword from
cmdline= to proctitle=

re-adding mailing list, accidentally dropped.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
