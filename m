Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 52A9D6B025F
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 22:54:14 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e3so17793649pfc.4
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 19:54:14 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0096.outbound.protection.outlook.com. [104.47.38.96])
        by mx.google.com with ESMTPS id z35si811462plh.730.2017.07.19.19.54.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 19 Jul 2017 19:54:13 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH v9 05/10] mm: thp: enable thp migration in generic path
Date: Wed, 19 Jul 2017 22:54:04 -0400
Message-ID: <A0ABA698-7486-46C3-B209-E95A9048B22C@cs.rutgers.edu>
In-Reply-To: <20170719135927.d553f5afe893ca43d70cbdc5@linux-foundation.org>
References: <201707191504.G4xCE7El%fengguang.wu@intel.com>
 <A5D98DDB-2295-467D-8368-D0A037CC2DC7@cs.rutgers.edu>
 <20170719135927.d553f5afe893ca43d70cbdc5@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, dnellans@nvidia.com, dave.hansen@intel.com, n-horiguchi@ah.jp.nec.com

On 19 Jul 2017, at 16:59, Andrew Morton wrote:

> On Wed, 19 Jul 2017 14:39:43 -0400 "Zi Yan" <zi.yan@cs.rutgers.edu> =

> wrote:
>
>> On 19 Jul 2017, at 4:04, kbuild test robot wrote:
>>
>>> Hi Zi,
>>>
>>> [auto build test WARNING on mmotm/master]
>>> [also build test WARNING on v4.13-rc1 next-20170718]
>>> [if your patch is applied to the wrong git tree, please drop us a =

>>> note to help improve the system]
>>>
>>> url:    =

>>> https://na01.safelinks.protection.outlook.com/?url=3Dhttps%3A%2F%2Fgi=
thub.com%2F0day-ci%2Flinux%2Fcommits%2FZi-Yan%2Fmm-page-migration-enhance=
ment-for-thp%2F20170718-095519&data=3D02%7C01%7Czi.yan%40cs.rutgers.edu%7=
Ca711ac47d4c0436ef66f08d4ce7cf30c%7Cb92d2b234d35447093ff69aca6632ffe%7C1%=
7C0%7C636360483431631457&sdata=3DNpxRpWbxe6o56xDJYpw1K6wgQo11IPCAbG2tE8l%=
2BU6E%3D&reserved=3D0
>>> base:   git://git.cmpxchg.org/linux-mmotm.git master
>>> config: xtensa-common_defconfig (attached as .config)
>>> compiler: xtensa-linux-gcc (GCC) 4.9.0
>>> reproduce:
>>>         wget =

>>> https://na01.safelinks.protection.outlook.com/?url=3Dhttps%3A%2F%2Fra=
w.githubusercontent.com%2F01org%2Flkp-tests%2Fmaster%2Fsbin%2Fmake.cross&=
data=3D02%7C01%7Czi.yan%40cs.rutgers.edu%7Ca711ac47d4c0436ef66f08d4ce7cf3=
0c%7Cb92d2b234d35447093ff69aca6632ffe%7C1%7C0%7C636360483431631457&sdata=3D=
rBCfu0xUg3v%2B8r%2Be2tsiqRcqw%2FEZSTa4OtF0hU%2FqMbc%3D&reserved=3D0 =

>>> -O ~/bin/make.cross
>>>         chmod +x ~/bin/make.cross
>>>         # save the attached .config to linux build tree
>>>         make.cross ARCH=3Dxtensa
>>>
>>> All warnings (new ones prefixed by >>):
>>>
>>>    In file included from mm/vmscan.c:55:0:
>>>    include/linux/swapops.h: In function 'swp_entry_to_pmd':
>>>>> include/linux/swapops.h:220:2: warning: missing braces around =

>>>>> initializer [-Wmissing-braces]
>>>      return (pmd_t){ 0 };
>>>      ^
>>>    include/linux/swapops.h:220:2: warning: (near initialization for =

>>> '(anonymous).pud') [-Wmissing-braces]
>>>
>>> vim +220 include/linux/swapops.h
>>>
>>>    217	=

>>>    218	static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
>>>    219	{
>>>> 220		return (pmd_t){ 0 };
>>>    221	}
>>>    222	=

>>
>> It is a GCC 4.9.0 bug: =

>> https://na01.safelinks.protection.outlook.com/?url=3Dhttps%3A%2F%2Fgcc=
=2Egnu.org%2Fbugzilla%2Fshow_bug.cgi%3Fid%3D53119&data=3D02%7C01%7Czi.yan=
%40cs.rutgers.edu%7C07c903c4f1444958942508d4cee90ca7%7Cb92d2b234d35447093=
ff69aca6632ffe%7C1%7C0%7C636360947714283172&sdata=3D84%2BXG7hglTCsTjGA8G3=
jyL7%2BFupkQaMkjAwzofffA5A%3D&reserved=3D0
>>
>> Upgrading GCC can get rid of this warning.
>
> I think there was a workaround for this, but I don't recall what it
> was.
>
> This suppressed the warning:
>
> --- a/include/linux/swapops.h~a
> +++ a/include/linux/swapops.h
> @@ -217,7 +217,7 @@ static inline swp_entry_t pmd_to_swp_ent
>
>  static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
>  {
> -	return (pmd_t){ 0 };
> +	return (pmd_t){};
>  }
>
>  static inline int is_pmd_migration_entry(pmd_t pmd)
>
> But I don't know if this is the approved workaround and I don't know
> what it will do at runtime!
>
> But we should fix this.  Expecting zillions of people to update their
> compiler version isn't nice.


How about this one?

--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -219,7 +219,7 @@ static inline swp_entry_t pmd_to_swp_entry(pmd_t =

pmd)

  static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
  {
-       return (pmd_t){ 0 };
+       return __pmd(0);
  }

  static inline int is_pmd_migration_entry(pmd_t pmd)


No warning or error was present during i386 kernel compilations
with gcc-4.9.3 or gcc-6.4.0. i386 gcc should share the same front-end
as xtensa-linux-gcc.

__pmd() should be the standard way of making pmd entries, right?


--
Best Regards
Yan Zi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
