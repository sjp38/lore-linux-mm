Received: by mu-out-0910.google.com with SMTP id i2so2046692mue.6
        for <linux-mm@kvack.org>; Sun, 30 Nov 2008 11:38:22 -0800 (PST)
Message-ID: <4932EBAA.60808@gmail.com>
Date: Sun, 30 Nov 2008 21:38:18 +0200
From: =?ISO-8859-1?Q?T=F6r=F6k_Edwin?= <edwintorok@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC v1][PATCH]page_fault retry with NOPAGE_RETRY
References: <492E6849.6090205@google.com> <492E8708.4060601@gmail.com> <20081127120330.GM28285@wotan.suse.de> <492E90BC.1090208@gmail.com> <20081127123926.GN28285@wotan.suse.de> <492E97FA.5000804@gmail.com> <20081127130525.GO28285@wotan.suse.de> <492E9C3C.9050507@gmail.com> <20081127131215.GQ28285@wotan.suse.de> <492E9F42.6010808@gmail.com> <20081128121015.GC13786@wotan.suse.de>
In-Reply-To: <20081128121015.GC13786@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Mike Waychison <mikew@google.com>, Ying Han <yinghan@google.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On 2008-11-28 14:10, Nick Piggin wrote:
> This is what I have.
>
> It does two things. Firstly, it switches x86-64 over to use the xadd
> algorithm rather than the spinlock algorithm. This is actually significant
> in high contention situations, because the spinlock algorithm doesn't allow
> concurrent operations on the lock while the queue of waiters is being
> manipulated.
>
> Secondly, it moves wakeups out from underneath the waiter queue lock. This
> is more significant on bigger machines where wakeup latency is worse and/or
> runqueue locks are very heavily contended.
>
> Now both these changes are going to help *mainly* for the case when there are
> a significant number of readers and writers, I think. So your write-heavy
> workload may not win anything. I noticed some speedup a long time ago on
> some weird java (volanomark) workload.

Hi,

I just tested your patch on top of tip/master, and my testprogram has
segfaulted :(
It is either something wrong in tip/master or the patch, or my program.
This is the first time this testprogram segfaults, and it doesn't have a
reason to segfault there.


[  140.624155] scalability[4995]: segfault at 7f9ce137f000 ip
0000000000401a62 sp 00000000454950a0 error 4 in scalability[400000+3000]
[  401.640738] scalability[5398]: segfault at 7fdbffba3000 ip
0000000000401a62 sp 00000000423d70a0 error 4 in scalability[400000+3000]

Here is the relevant portion, at 401a62 I read from the mapping:

static void mmap_worker_fn(int fd, off_t len)
{
    char *data = mmap(NULL, len, PROT_READ, MAP_PRIVATE, fd, 0);
  401a4f:    48 89 c7                 mov    %rax,%rdi
    if(data == MAP_FAILED) {
  401a52:    74 36                    je     401a8a <mmap_worker_fn+0x5a>
        perror("mmap");
        abort();
  401a54:    31 d2                    xor    %edx,%edx
  401a56:    31 c9                    xor    %ecx,%ecx
static pthread_mutex_t thrtime_mtx = PTHREAD_MUTEX_INITIALIZER;

static size_t execute(const char *data, size_t len)
{
    size_t sum = 0, i;
    for(i=0;i<len;++i)
  401a58:    48 85 db                 test   %rbx,%rbx
  401a5b:    74 28                    je     401a85 <mmap_worker_fn+0x55>
  401a5d:    0f 1f 00                 nopl   (%rax)
        if(data[i] == 'd')
            ++sum;
  401a60:    31 c0                    xor    %eax,%eax
  401a62:    80 3c 17 64              cmpb   $0x64,(%rdi,%rdx,1)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
This simply reads from the mapping

  401a66:    0f 94 c0                 sete   %al
static pthread_mutex_t thrtime_mtx = PTHREAD_MUTEX_INITIALIZER;

Steps to reproduce:
# sync; echo 3 >/proc/sys/vm/drop_caches; sync
# echo 0 >/proc/lock_stat
$ sudo ./scalability 16 /usr/bin/
... prints out results for read, and while running mmap_worker ...
... a message about segmentation fault ....

The testprogram is available here:
http://edwintorok.googlepages.com/tst.tar.gz

My .config:
http://edwintorok.googlepages.com/config

Can you reproduce the crash on your box?
Can I help debugging the problem?

Best regards,
--Edwin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
