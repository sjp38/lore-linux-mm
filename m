Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 94F056B04A7
	for <linux-mm@kvack.org>; Sat, 19 Nov 2016 13:47:30 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q10so310823830pgq.7
        for <linux-mm@kvack.org>; Sat, 19 Nov 2016 10:47:30 -0800 (PST)
Received: from out01.mta.xmission.com (out01.mta.xmission.com. [166.70.13.231])
        by mx.google.com with ESMTPS id o63si14103710pfi.114.2016.11.19.10.47.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Nov 2016 10:47:29 -0800 (PST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <CALCETrU4SZYUEPrv4JkpUpA+0sZ=EirZRftRDp+a5hce5E7HgA@mail.gmail.com>
	<87y41kjn6l.fsf@xmission.com> <20161019172917.GE1210@laptop.thejh.net>
	<CALCETrWSY1SRse5oqSwZ=goQ+ZALd2XcTP3SZ8ry49C8rNd98Q@mail.gmail.com>
	<87pomwi5p2.fsf@xmission.com>
	<CALCETrUz2oU6OYwQ9K4M-SUg6FeDsd6Q1gf1w-cJRGg2PdmK8g@mail.gmail.com>
	<87pomwghda.fsf@xmission.com>
	<CALCETrXA2EnE8X3HzetLG6zS8YSVjJQJrsSumTfvEcGq=r5vsw@mail.gmail.com>
	<87twb6avk8.fsf_-_@xmission.com> <20161119071700.GA13347@1wt.eu>
	<20161119092804.GA13553@1wt.eu>
Date: Sat, 19 Nov 2016 12:44:49 -0600
In-Reply-To: <20161119092804.GA13553@1wt.eu> (Willy Tarreau's message of "Sat,
	19 Nov 2016 10:28:04 +0100")
Message-ID: <87vavjia1q.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [REVIEW][PATCH 0/3] Fixing ptrace vs exec vs userns interactions
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Willy Tarreau <w@1wt.eu>
Cc: Linux Containers <containers@lists.linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Jann Horn <jann@thejh.net>, Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@amacapital.net>

Willy Tarreau <w@1wt.eu> writes:

> On Sat, Nov 19, 2016 at 08:17:00AM +0100, Willy Tarreau wrote:
>> Hi Eric,
>> 
>> On Thu, Nov 17, 2016 at 11:02:47AM -0600, Eric W. Biederman wrote:
>> > 
>> > With everyone heading to Kernel Summit and Plumbers I put this set of
>> > patches down temporarily.   Now is the time to take it back up and to
>> > make certain I am not missing something stupid in this set of patches.
>> 
>> I couldn't get your patch set to apply to any of the kernels I tried,
>> I manually adjusted some parts but the second one has too many rejects.
>> What kernel should I apply this to ? Or maybe some preliminary patches
>> are needed ?
>
> OK I finally managed to get it to work on top of 4.8.9 (required less changes
> than master). I also had to drop the user_ns changes since there's no such
> user_ns in mm_struct there.
>
> I could run a test on it, that looks reasonable :
>
> FS:
>
> admin@vm:~$ strace -e trace=fstat,uname,ioctl,open uname
> open(0x7ffd01bbeeb0, O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
> open(0x7ffd01bbeeb0, O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
> open(0x7ffd01bbeeb0, O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
> open(0x7ffd01bbeeb0, O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
> open(0x7f3f9a1663e3, O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
> open(0x7ffd01bbeeb0, O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
> open(0x7ffd01bbeeb0, O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
> open(0x7ffd01bbeeb0, O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
> open(0x7ffd01bbeeb0, O_RDONLY|O_CLOEXEC) = 3
> fstat(3, {...})                         = 0
> open(0x7ffd01bbee80, O_RDONLY|O_CLOEXEC) = 3
> fstat(3, {...})                         = 0
> uname({...})                            = 0
> fstat(1, {...})                         = 0
> ioctl(1, SNDCTL_TMR_TIMEBASE or TCGETS, 0x7ffd01bbf400) = 0
>
> admin@vm:~$ sudo strace -e trace=fstat,uname,ioctl,open uname
> open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
> open("/lib64/tls/x86_64/libpthread.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
> open("/lib64/tls/libpthread.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
> open("/lib64/x86_64/libpthread.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
> open("/lib64/libpthread.so.0", O_RDONLY|O_CLOEXEC) = 3
> fstat(3, {st_mode=S_IFREG|0555, st_size=101312, ...}) = 0
> open("/lib64/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
> fstat(3, {st_mode=S_IFREG|0555, st_size=1479016, ...}) = 0
> uname({sys="Linux", node="vm", ...})    = 0
> fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(4, 64), ...}) = 0
> ioctl(1, SNDCTL_TMR_TIMEBASE or TCGETS, {B9600 opost isig icanon echo ...}) = 0
>
> Network:
>
> admin@vm:~$ strace -e trace=socket,setsockopt,connect /tmp/nc 198.18.3 22
> socket(PF_FILE, SOCK_STREAM|SOCK_CLOEXEC|SOCK_NONBLOCK, 0) = 3
> connect(3, {...}, 110)                  = -1 ENOENT (No such file or directory)
> socket(PF_FILE, SOCK_STREAM|SOCK_CLOEXEC|SOCK_NONBLOCK, 0) = 3
> connect(3, {...}, 110)                  = -1 ENOENT (No such file or directory)
> socket(PF_INET, SOCK_STREAM, IPPROTO_TCP) = 3
> setsockopt(3, SOL_SOCKET, SO_REUSEADDR, 0x7ffd2c26bdbc, 4) = 0
> connect(3, {...}, 16)                   = 0
>
> admin@vm:~$ sudo strace -e trace=socket,setsockopt,connect /tmp/nc 198.18.3 22
> socket(PF_FILE, SOCK_STREAM|SOCK_CLOEXEC|SOCK_NONBLOCK, 0) = 3
> connect(3, {sa_family=AF_FILE, path="/var/run/nscd/socket"}, 110) = -1 ENOENT (No such file or directory)
> socket(PF_FILE, SOCK_STREAM|SOCK_CLOEXEC|SOCK_NONBLOCK, 0) = 3
> connect(3, {sa_family=AF_FILE, path="/var/run/nscd/socket"}, 110) = -1 ENOENT (No such file or directory)
> socket(PF_INET, SOCK_STREAM, IPPROTO_TCP) = 3
> setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
> connect(3, {sa_family=AF_INET, sin_port=htons(22), sin_addr=inet_addr("198.18.0.3")}, 16) = 0
>
> So in short now we can at least see what syscall fails eventhough we can't
> know why. I think it can be an acceptable trade-off.

Thanks for testing, and thanks for you acceptance even if I didn't make
it easy for you.


Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
