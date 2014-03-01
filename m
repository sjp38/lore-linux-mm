Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f170.google.com (mail-ve0-f170.google.com [209.85.128.170])
	by kanga.kvack.org (Postfix) with ESMTP id AFF276B006C
	for <linux-mm@kvack.org>; Sat,  1 Mar 2014 01:27:45 -0500 (EST)
Received: by mail-ve0-f170.google.com with SMTP id pa12so1750520veb.29
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 22:27:45 -0800 (PST)
Received: from mail-vc0-x230.google.com (mail-vc0-x230.google.com [2607:f8b0:400c:c03::230])
        by mx.google.com with ESMTPS id cz20si1176590veb.129.2014.02.28.22.27.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 28 Feb 2014 22:27:45 -0800 (PST)
Received: by mail-vc0-f176.google.com with SMTP id la4so1683881vcb.35
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 22:27:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CACQD4-7UUDMeXdR-NaAAXvk-NRYqW7mHJkjDUM=JRvL54b_Xsg@mail.gmail.com>
References: <1393625931-2858-1-git-send-email-quning@google.com>
 <CACQD4-5U3P+QiuNKzt5+VdDDi0ocphR+Jh81eHqG6_+KeaHyRw@mail.gmail.com>
 <20140228174150.8ff4edca.akpm@linux-foundation.org> <CACQD4-7UUDMeXdR-NaAAXvk-NRYqW7mHJkjDUM=JRvL54b_Xsg@mail.gmail.com>
From: Ning Qu <quning@gmail.com>
Date: Fri, 28 Feb 2014 22:27:04 -0800
Message-ID: <CACQD4-5SmUf+krLbef9Yg9HhJ-ipT2QKKq-NW=2C6G=XwXcMcQ@mail.gmail.com>
Subject: Re: [PATCH 0/1] mm, shmem: map few pages around fault address if they
 are in page cache
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Yes, the simple test does verify that the page fault number are
correct with the patch. So my previous results are from those command
lines, which also show some performance improvement with this change
in tmpfs.

sequential access
/usr/bin/time -a ./iozone =E2=80=94B s 8g -i 0 -i 1

random access
/usr/bin/time -a ./iozone =E2=80=94B s 8g -i 0 -i 2
Best wishes,
--=20
Ning Qu


On Fri, Feb 28, 2014 at 10:10 PM, Ning Qu <quning@gmail.com> wrote:
> Yes, I am using the iozone -i 0 -i 1. Let me try the most simple test
> as you mentioned.
> Best wishes,
> --
> Ning Qu
>
>
> On Fri, Feb 28, 2014 at 5:41 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>> On Fri, 28 Feb 2014 16:35:16 -0800 Ning Qu <quning@gmail.com> wrote:
>>
>>> Sorry about my fault about the experiments, here is the real one.
>>>
>>> Btw, apparently, there are still some questions about the results and
>>> I will sync with Kirill about his test command line.
>>>
>>> Below is just some simple experiment numbers from this patch, let me kn=
ow if
>>> you would like more:
>>>
>>> Tested on Xeon machine with 64GiB of RAM, using the current default fau=
lt
>>> order 4.
>>>
>>> Sequential access 8GiB file
>>>                         Baseline        with-patch
>>> 1 thread
>>>     minor fault         8,389,052    4,456,530
>>>     time, seconds    9.55            8.31
>>
>> The numbers still seem wrong.  I'd expect to see almost exactly 2M minor
>> faults with this test.
>>
>> Looky:
>>
>> #include <sys/mman.h>
>> #include <stdio.h>
>> #include <unistd.h>
>> #include <stdlib.h>
>> #include <sys/types.h>
>> #include <sys/stat.h>
>> #include <fcntl.h>
>>
>> #define G (1024 * 1024 * 1024)
>>
>> int main(int argc, char *argv[])
>> {
>>         char *p;
>>         int fd;
>>         unsigned long idx;
>>         int sum =3D 0;
>>
>>         fd =3D open("foo", O_RDONLY);
>>         if (fd < 0) {
>>                 perror("open");
>>                 exit(1);
>>         }
>>         p =3D mmap(NULL, 1 * G, PROT_READ, MAP_PRIVATE, fd, 0);
>>         if (p =3D=3D MAP_FAILED) {
>>                 perror("mmap");
>>                 exit(1);
>>         }
>>
>>         for (idx =3D 0; idx < 1 * G; idx +=3D 4096)
>>                 sum +=3D p[idx];
>>         printf("%d\n", sum);
>>         exit(0);
>> }
>>
>> z:/home/akpm> /usr/bin/time ./a.out
>> 0
>> 0.05user 0.33system 0:00.38elapsed 99%CPU (0avgtext+0avgdata 4195856maxr=
esident)k
>> 0inputs+0outputs (0major+262264minor)pagefaults 0swaps
>>
>> z:/home/akpm> dc
>> 16o
>> 262264 4 * p
>> 1001E0
>>
>> That's close!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
