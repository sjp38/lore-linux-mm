Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id F057444043C
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 14:08:50 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id 189so6327432iow.8
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 11:08:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e1sor2648244ith.134.2017.11.08.11.08.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Nov 2017 11:08:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAGXu5jLj2NZEhwR_kpuAnJdChmE3V5fMS3Ry9FnncL5XdxVJkA@mail.gmail.com>
References: <001a114096fec09301055d68d784@google.com> <CAGXu5jJFwPYre6P2vf1v0XFBFfk-uqJEYEPP8WsjPspZoYDHCg@mail.gmail.com>
 <CACT4Y+bkTWRcrun95FbfiJseJjzt9z7JXONVJ9N2Hqo1-8yVuA@mail.gmail.com> <CAGXu5jLj2NZEhwR_kpuAnJdChmE3V5fMS3Ry9FnncL5XdxVJkA@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 8 Nov 2017 20:08:29 +0100
Message-ID: <CACT4Y+aOgosKend119L9frRHacnXVZT=+jzZivP7DWFOPx8+pQ@mail.gmail.com>
Subject: Re: WARNING in __check_heap_object
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: syzbot <bot+2357afb48acb76780f3c18867ccfb7aa6fd6c4c9@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, syzkaller-bugs@googlegroups.com, David Windsor <dave@nullcore.net>

On Wed, Nov 8, 2017 at 8:02 PM, Kees Cook <keescook@chromium.org> wrote:
>>> On Tue, Nov 7, 2017 at 10:36 AM, syzbot
>>> <bot+2357afb48acb76780f3c18867ccfb7aa6fd6c4c9@syzkaller.appspotmail.com>
>>> wrote:
>>>> Hello,
>>>>
>>>> syzkaller hit the following crash on
>>>> 5a3517e009e979f21977d362212b7729c5165d92
>>>> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
>>>> compiler: gcc (GCC) 7.1.1 20170620
>>>> .config is attached
>>>> Raw console output is attached.
>>>> C reproducer is attached
>>>> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
>>>> for information about syzkaller reproducers
>>>>
>>>>
>>>
>>> Please include the line _before_ the "cut here" (dumb, I know, but
>>> that's where warnings show up...)
>>>
>>> Found in the raw.log:
>>>
>>> [   44.227177] unexpected usercopy without slab whitelist from SCTPv6
>>> offset 1648 size 11
>>>
>>> This means some part of the SCTPv6 slab was being poked into userspace
>>> without a usercopy whitelist.
>>>
>>>>  check_heap_object mm/usercopy.c:222 [inline]
>>>>  __check_object_size+0x22c/0x4f0 mm/usercopy.c:248
>>>>  check_object_size include/linux/thread_info.h:112 [inline]
>>>>  check_copy_size include/linux/thread_info.h:143 [inline]
>>>>  copy_to_user include/linux/uaccess.h:154 [inline]
>>>>  sctp_getsockopt_events net/sctp/socket.c:4972 [inline]
>>>>  sctp_getsockopt+0x2b90/0x70b0 net/sctp/socket.c:7012
>>>>  sock_common_getsockopt+0x95/0xd0 net/core/sock.c:2924
>>>>  SYSC_getsockopt net/socket.c:1882 [inline]
>>>>  SyS_getsockopt+0x178/0x340 net/socket.c:1864
>>>>  entry_SYSCALL_64_fastpath+0x1f/0xbe
>>>
>>> Looking at the SCTPv6 slab declaration, it seems David and I missed
>>> the usercopy whitelist for the sctpv6_sock struct. I'll update the
>>> usercopy whitelist patch with:
>>>
>>> #syz fix: sctp: Define usercopy region in SCTP proto slab cache
>>>
>>> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
>>> index 5fd83974c5cc..8ac85877c0e4 100644
>>> --- a/net/sctp/socket.c
>>> +++ b/net/sctp/socket.c
>>> @@ -8492,6 +8492,10 @@ struct proto sctpv6_prot = {
>>>         .unhash         = sctp_unhash,
>>>         .get_port       = sctp_get_port,
>>>         .obj_size       = sizeof(struct sctp6_sock),
>>> +       .useroffset     = offsetof(struct sctp_sock, subscribe),
>>> +       .usersize       = offsetof(struct sctp_sock, initmsg) -
>>> +                               offsetof(struct sctp_sock, subscribe) +
>>> +                               sizeof_field(struct sctp_sock, initmsg),
>>>         .sysctl_mem     = sysctl_sctp_mem,
>>>         .sysctl_rmem    = sysctl_sctp_rmem,
>>>         .sysctl_wmem    = sysctl_sctp_wmem,
>>>
>>> Thanks!
>>
>>
>> Kees, please also follow this part once the commit reaches any of
>> trees (title is settled):
>>
>>> syzbot will keep track of this bug report.
>>> Once a fix for this bug is committed, please reply to this email with:
>>> #syz fix: exact-commit-title
>>> Note: all commands must start from beginning of the line.
>>
>> This will greatly help to keep the whole process running and report
>> new bugs in future.
>
> I included that in my email reply already, and the commit will be in
> -next shortly. (Do you prefer something else?)


Doh! That's just me trying to handle 200 bugs at the same time. Sorry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
