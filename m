Message-ID: <46A51384.2020509@oracle.com>
Date: Mon, 23 Jul 2007 13:45:56 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
MIME-Version: 1.0
Subject: Re: hugepage test failures
References: <20070723120409.477a1c31.randy.dunlap@oracle.com>	 <29495f1d0707231318n5e76d141t5f81431ead007b53@mail.gmail.com>	 <46A50FD0.2020001@oracle.com> <29495f1d0707231329y5db98284y5ade99eee7305c23@mail.gmail.com>
In-Reply-To: <29495f1d0707231329y5db98284y5ade99eee7305c23@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nish Aravamudan <nish.aravamudan@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nish Aravamudan wrote:
> On 7/23/07, Randy Dunlap <randy.dunlap@oracle.com> wrote:
>> Nish Aravamudan wrote:
>> > On 7/23/07, Randy Dunlap <randy.dunlap@oracle.com> wrote:
>> >> Hi,
>> >>
>> >> I'm a few hundred linux-mm emails behind, so maybe this has been
>> >> addressed already.  I hope so.
>> >>
>> >> I run hugepage-mmap and hugepage-shm tests (from 
>> Doc/vm/hugetlbpage.txt)
>> >> on a regular basis.  Lately they have been failing, usually with 
>> -ENOMEM,
>> >> but sometimes the mmap() succeeds and hugepage-mmap gets a SIGBUS:
>> >
>> > Would it be possible for you instead to run the libhugetlbfs tests?
>>
>> OK, I'm downloading that now.
> 
> Great, thanks. I believe the same tests that are intended by
> Doc/vm/hugetlbpage.txt will be run by `make func`.
> 
>> > They are kept uptodate, at least.
>>
>> You mean that the Doc/ tree is not kept up to date?  ;(
> 
> Well, I think we all know that is true. But I wasn't aware there was a
> testcase in the Documentation directory. I'll see what I can do about
> making sure that is uptodate.

You could begin with my (old) patch to make them standalone .c files
instead of being buried in a txt file.  (All programs in Doc/ should
be like this IMO.)

>> But this represents an R*word (regression).
>> These tests ran successfully until recently (I can't say when).
> 
> Ok. I'm not sure a lot of hugetlb.c stuff has gone in very recently.
> Any chance you can narrow down the window?

Maybe.

>> >> open("/mnt/hugetlbfs/hugepagefile", O_RDWR|O_CREAT, 0755) = 3
>> >> mmap(NULL, 268435456, PROT_READ|PROT_WRITE, MAP_SHARED, 3, 0) =
>> >> 0x2af31d2c3000
>> >> fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 1), ...}) = 0
>> >> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
>> >> 0) = 0x2af32d2c3000
>> >> write(1, "Returned address is 0x2af31d2c30"..., 35) = 35
>> >> --- SIGBUS (Bus error) @ 0 (0) ---
>> >> +++ killed by SIGBUS +++
>> >>
>> >>
>> >> and:
>> >>
>> >> # ./hugepage-shm
>> >> shmget: Cannot allocate memory
>> >>
>> >>
>> >> I added printk()s in many mm/mmap.c and mm/hugetlb.c error return
>> >> locations and got this:
>> >>
>> >> hugetlb_reserve_pages: -ENOMEM
>> >>
>> >> which comes from mm/hugetlb.c::hugetlb_reserve_pages():
>> >>
>> >>         if (chg > cpuset_mems_nr(free_huge_pages_node)) {
>> >>                 printk(KERN_DEBUG "%s: -ENOMEM\n", __func__);
>> >>                 return -ENOMEM;
>> >>         }
>> >>
>> >> I had CONFIG_CPUSETS=y so I disabled it, but the same error
>> >> still happens.
>> >
>> > As in the same cpusets_mems_nr() check fails?
>> >
>> >> Suggestions?  Fixex?
>> >
>> > Which kernel is this?
>>
>> Ah, sorry, 2.6.23-rc1.
> 
> Architecture? I'll try and reproduce here.

x86_64.

-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
