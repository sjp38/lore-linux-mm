Date: Thu, 26 Jul 2007 11:58:29 +0200
From: =?iso-8859-1?Q?Bj=F6rn?= Steinbrink <B.Steinbrink@gmx.de>
Subject: Re: updatedb
Message-ID: <20070726095829.GA26987@atjola.homenet>
References: <367a23780707250830i20a04a60n690e8da5630d39a9@mail.gmail.com> <a491f91d0707251015x75404d9fld7b3382f69112028@mail.gmail.com> <46A81C39.4050009@gmail.com> <200707260839.51407.bhlope@mweb.co.za> <46A845BB.9080503@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <46A845BB.9080503@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: Bongani Hlope <bhlope@mweb.co.za>, Robert Deaton <false.hopes@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 2007.07.26 08:56:59 +0200, Rene Herman wrote:
> On 07/26/2007 08:39 AM, Bongani Hlope wrote:
>
>> On Thursday 26 July 2007 05:59:53 Rene Herman wrote:
>
>>> So what's happening? If you sit down with a copy op "top" in one terminal
>>> and updatedb in another, what does it show?
>
>> Just tested that, there's a steady increase in the useage of buff
>
> Great. Now concentrate on the "swpd" column, as it's the only thing 
> relevant here. The fact that an updatedb run fills/replaces caches is 
> completely and utterly unsurprising and not something swap-prefetch helps 
> with. The only thing it does is bring back stuff from _swap_.

But that's with a system that has plenty of RAM available.

The following vmstat output is from a run for which I ran a memory hog
to simulate a box with just 1GB of RAM (didn't want to reboot ;-)). That
(or even less) is probably a more likely amount of RAM for a majority of
users.

Other than the memory hog, there's a relatively small Firefox process
(just about 150MB RSS), Xorg, mutt an apache and some other stuff,
leaving about 128MB of RAM "free".

procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 0  0    696  16360  47608  74600    0    0     7    13    4   30  0  0 99  0
 0  0    696  16352  47608  74600    0    0     0    48  213  530  0  0 100  0
 0  1    796  16024  45516  74548    0   17   882   160  515 1698  1  3 58 38
 0  1   1092  16124  41752  74164    0   43  1931    43  660 2219  1  4 50 45
 1  1   1548  35096  24224  69036    0  107  1115   571  473 1616  1  4 50 45
 2  1   8980  45560  18552  58580    0 1324  1069  1324  453 1705  1  4 50 45
 2  1  12460  44840  21048  56588    0 1160   831  1345  403 1351  0  1 51 48
 2  1  14348  44220  23016  55408    0  629   661   947  353 1140  0  2 50 48
 [snip]
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 3  1  88904  72160  55368  38908    0 1377   836  1576  424 1403  0  3 50 47
 0  1  96080  74084  57600  38660    0 2373   747  2559  412 1312  0  2 48 49
 1  1 100036  74816  61544  38660    0 1319  1312  1547  524 1605  1  3 50 47
 0  1 107032  72996  64728  37780    4 2332  1065  2341  461 1686  1  5 50 45
 2  1 115036  68944  75908  36768    0 2660  3731  2941 1133 3721  1  6 49 44
 3  0 125160  58768  90548  36628    0 3375  4883  3798 1458 4606  1  6 50 43
 2  1 125176  48560 102364  36536    0    5  3973  1377 1342 3701  1  4 50 46
 [snip]
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 5  1 360628 101444 191420  34496    0  748  1927   760  670 2322  3  3 48 46
 1  0 362064 100996 191972  34520    0  479   184   479  226  654 50  1 41  8
 1  0 362064  99752 191980  34520    0    0     0     9  182  594 50  0 50  0
 4  0 362064  98728 191980  34520   11    0    11     5  179  588 49  0 50  0
 2  0 362064  97528 191988  34520    0    0     0    15  188  603 50  0 50  0
 2  0 362064  95876 191988  34520   43    0    43    13  190  603 50  0 49  1
 1  0 362064  95008 191996  34520   21    0    21    12  183  604 50  0 50  0
 2  0 364900  63516 193212  63456    0  947   408  1281  368 1163 16  3 50 31
 0  0 364868 139108 193284  39220    0    0    69 11213  383 15413 25  8 61  6
 1  0 364868 139116 193312  39220    0    0     0  1284  224  595  0  0 98  1
 2  0 364868 139240 193320  39220    0    0     0     9  182  553  0  0 100  0


Note that the total RSS usage of updatedb+sort was just about 50MB,
nevertheless swap grew to more than 300MB. It's also interesting that
swapping is so aggressive, that the amount of free memory is constantly
growing. I'm a missing something or wouldn't it be smarter to use that
free memory for buffers and cache first? (x86_64 system, so even if
highmem on x86 could be responsible, it's not the case here.)

Will now go and see what happens if I play with swappiness.

Bjorn

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
