Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 53B796B0006
	for <linux-mm@kvack.org>; Sat, 21 Jul 2018 00:00:16 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id n19-v6so7130157pgv.14
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 21:00:16 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 200-v6si3301452pgf.378.2018.07.20.21.00.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 21:00:14 -0700 (PDT)
Date: Sat, 21 Jul 2018 11:59:55 +0800
From: kbuild test robot <lkp@intel.com>
Subject: [mmotm:master 171/351] mm/vmacache.c:14:39: error: 'PMD_SHIFT'
 undeclared; did you mean 'PUD_SHIFT'?
Message-ID: <201807211152.qkpCcW5b%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="9amGYk9869ThD9tj"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   51e69b1d3de18116a5dceb6b144444dfdf136dc7
commit: 77ecf9bc0e3d673d4d561cedc1d01c7a84ef90b7 [171/351] mm, vmacache: hash addresses based on pmd
config: arm-allnoconfig (attached as .config)
compiler: arm-linux-gnueabi-gcc (Debian 7.2.0-11) 7.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 77ecf9bc0e3d673d4d561cedc1d01c7a84ef90b7
        # save the attached .config to linux build tree
        GCC_VERSION=7.2.0 make.cross ARCH=arm 

All error/warnings (new ones prefixed by >>):

   mm/vmacache.c: In function 'vmacache_update':
>> mm/vmacache.c:14:39: error: 'PMD_SHIFT' undeclared (first use in this function); did you mean 'PUD_SHIFT'?
    #define VMACACHE_HASH(addr) ((addr >> PMD_SHIFT) & VMACACHE_MASK)
                                          ^
>> mm/vmacache.c:71:26: note: in expansion of macro 'VMACACHE_HASH'
      current->vmacache.vmas[VMACACHE_HASH(addr)] = newvma;
                             ^~~~~~~~~~~~~
   mm/vmacache.c:14:39: note: each undeclared identifier is reported only once for each function it appears in
    #define VMACACHE_HASH(addr) ((addr >> PMD_SHIFT) & VMACACHE_MASK)
                                          ^
>> mm/vmacache.c:71:26: note: in expansion of macro 'VMACACHE_HASH'
      current->vmacache.vmas[VMACACHE_HASH(addr)] = newvma;
                             ^~~~~~~~~~~~~
   mm/vmacache.c: In function 'vmacache_find':
>> mm/vmacache.c:14:39: error: 'PMD_SHIFT' undeclared (first use in this function); did you mean 'PUD_SHIFT'?
    #define VMACACHE_HASH(addr) ((addr >> PMD_SHIFT) & VMACACHE_MASK)
                                          ^
   mm/vmacache.c:96:12: note: in expansion of macro 'VMACACHE_HASH'
     int idx = VMACACHE_HASH(addr);
               ^~~~~~~~~~~~~
   mm/vmacache.c: In function 'vmacache_find_exact':
>> mm/vmacache.c:127:26: error: 'addr' undeclared (first use in this function)
     int idx = VMACACHE_HASH(addr);
                             ^
   mm/vmacache.c:14:31: note: in definition of macro 'VMACACHE_HASH'
    #define VMACACHE_HASH(addr) ((addr >> PMD_SHIFT) & VMACACHE_MASK)
                                  ^~~~
>> mm/vmacache.c:14:39: error: 'PMD_SHIFT' undeclared (first use in this function); did you mean 'PUD_SHIFT'?
    #define VMACACHE_HASH(addr) ((addr >> PMD_SHIFT) & VMACACHE_MASK)
                                          ^
   mm/vmacache.c:127:12: note: in expansion of macro 'VMACACHE_HASH'
     int idx = VMACACHE_HASH(addr);
               ^~~~~~~~~~~~~

vim +14 mm/vmacache.c

     9	
    10	/*
    11	 * Hash based on the pmd of addr.  Provides a good hit rate for workloads with
    12	 * spatial locality.
    13	 */
  > 14	#define VMACACHE_HASH(addr) ((addr >> PMD_SHIFT) & VMACACHE_MASK)
    15	
    16	/*
    17	 * Flush vma caches for threads that share a given mm.
    18	 *
    19	 * The operation is safe because the caller holds the mmap_sem
    20	 * exclusively and other threads accessing the vma cache will
    21	 * have mmap_sem held at least for read, so no extra locking
    22	 * is required to maintain the vma cache.
    23	 */
    24	void vmacache_flush_all(struct mm_struct *mm)
    25	{
    26		struct task_struct *g, *p;
    27	
    28		count_vm_vmacache_event(VMACACHE_FULL_FLUSHES);
    29	
    30		/*
    31		 * Single threaded tasks need not iterate the entire
    32		 * list of process. We can avoid the flushing as well
    33		 * since the mm's seqnum was increased and don't have
    34		 * to worry about other threads' seqnum. Current's
    35		 * flush will occur upon the next lookup.
    36		 */
    37		if (atomic_read(&mm->mm_users) == 1)
    38			return;
    39	
    40		rcu_read_lock();
    41		for_each_process_thread(g, p) {
    42			/*
    43			 * Only flush the vmacache pointers as the
    44			 * mm seqnum is already set and curr's will
    45			 * be set upon invalidation when the next
    46			 * lookup is done.
    47			 */
    48			if (mm == p->mm)
    49				vmacache_flush(p);
    50		}
    51		rcu_read_unlock();
    52	}
    53	
    54	/*
    55	 * This task may be accessing a foreign mm via (for example)
    56	 * get_user_pages()->find_vma().  The vmacache is task-local and this
    57	 * task's vmacache pertains to a different mm (ie, its own).  There is
    58	 * nothing we can do here.
    59	 *
    60	 * Also handle the case where a kernel thread has adopted this mm via use_mm().
    61	 * That kernel thread's vmacache is not applicable to this mm.
    62	 */
    63	static inline bool vmacache_valid_mm(struct mm_struct *mm)
    64	{
    65		return current->mm == mm && !(current->flags & PF_KTHREAD);
    66	}
    67	
    68	void vmacache_update(unsigned long addr, struct vm_area_struct *newvma)
    69	{
    70		if (vmacache_valid_mm(newvma->vm_mm))
  > 71			current->vmacache.vmas[VMACACHE_HASH(addr)] = newvma;
    72	}
    73	
    74	static bool vmacache_valid(struct mm_struct *mm)
    75	{
    76		struct task_struct *curr;
    77	
    78		if (!vmacache_valid_mm(mm))
    79			return false;
    80	
    81		curr = current;
    82		if (mm->vmacache_seqnum != curr->vmacache.seqnum) {
    83			/*
    84			 * First attempt will always be invalid, initialize
    85			 * the new cache for this task here.
    86			 */
    87			curr->vmacache.seqnum = mm->vmacache_seqnum;
    88			vmacache_flush(curr);
    89			return false;
    90		}
    91		return true;
    92	}
    93	
    94	struct vm_area_struct *vmacache_find(struct mm_struct *mm, unsigned long addr)
    95	{
    96		int idx = VMACACHE_HASH(addr);
    97		int i;
    98	
    99		count_vm_vmacache_event(VMACACHE_FIND_CALLS);
   100	
   101		if (!vmacache_valid(mm))
   102			return NULL;
   103	
   104		for (i = 0; i < VMACACHE_SIZE; i++) {
   105			struct vm_area_struct *vma = current->vmacache.vmas[idx];
   106	
   107			if (vma) {
   108				if (WARN_ON_ONCE(vma->vm_mm != mm))
   109					break;
   110				if (vma->vm_start <= addr && vma->vm_end > addr) {
   111					count_vm_vmacache_event(VMACACHE_FIND_HITS);
   112					return vma;
   113				}
   114			}
   115			if (++idx == VMACACHE_SIZE)
   116				idx = 0;
   117		}
   118	
   119		return NULL;
   120	}
   121	
   122	#ifndef CONFIG_MMU
   123	struct vm_area_struct *vmacache_find_exact(struct mm_struct *mm,
   124						   unsigned long start,
   125						   unsigned long end)
   126	{
 > 127		int idx = VMACACHE_HASH(addr);

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--9amGYk9869ThD9tj
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

H4sICDmuUlsAAy5jb25maWcAjVxbk9u4jn4/v0KVqdpK6mwyfUsn2a1+oCnK4lgUFZKy3f2i
cmyl40rb7vVlZvLvF6AsWxfSc1IzlW4CvIEg8AGE8tu/fgvIYb9ZzfbL+ezl5VfwXK7L7Wxf
LoLvy5fyf4NQBqk0AQu5+QDMyXJ9+Pv32XYV3H24/vzh6v12/vH9anUdjMrtunwJ6Gb9ffl8
gBGWm/W/fvsX/PcbNK5eYbDt/wTQ8f0LDvH+eX0oZ9+W75/n8+BtWH5bztbBpw83MOL19bvq
J+hLZRrxYUGUePhV/6IfdaHzLJPK6IJkomAiT4jhMj3zpLLgEjkKQbJGV0PoyChCWT3CmZZI
OgpZ1ieoiWaimNJ4SMKwIMlQKm7ixoKGLGWK0yKeMD6MTZ9AScIHihhWhCwhj2cGomh83kue
KTlg+kzOYtiqjCLNzMPV31dXn6/wz4k6NGSQsCJhY5boh5u6ndKC62JIaWMh0DZmSqOMPl3d
nMegCUmHJ9JVdVxDqwIvwa7cH17PhzBQcsTSQqaFFg2Z8pSbgqVj2AwIkQtuHm5v8NCPM0iR
cVilYdoEy12w3uxx4IbUSVLP/+bNuV+TUJDcSEfnmIxZMWIqZUkxfOKNRTUpyZMgbsr0yddD
+gh3Z0J74tPCG7M2l9ylT58uUWEFl8l3DnGELCJ5YopYapMSwR7evF1v1uW7hlTh7ox5Rp1j
55qBmvrEbFWV5GAGYAw4mgT2bLWFq6/B7vBt92u3L1dnbal1H8iF1ev+tUCSjuXET6l0u3kW
KgQa3P9JoZhmaejuS+OmMmBLKAXhqautiDlTuLvH5jxpCDp7ZADedsdIKsrCwsSKkZCnw4aB
yYjSrN3DSo6iedEyh45FSAxxGAnkgO2mRteiNctVud25pBs/FRn0kiGnTd0DswcUDmt3nrAl
OykxGC6UaGG4gDvX5KkseJb/bma7n8EelhTM1otgt5/td8FsPt8c1vvl+vm8NsPpqIAOBaFU
5qmpBHSaaszBKrfJKAPnslDYuKIGb29piuaB7ksIeB8LoDWnhl8LNgXBuSyRrpib3XWnPx9V
Pzh616eoaQyaYc+y2ZMOlcwz7dxk1QVNnGVy8ij0G07KIBnBxR9bM6xCx8rA9MsMhMifGCou
6g38JUhKWWuFHTYNP/hsQc7D6/uzrCqRNgcDh2w42BPl3vCQGUH0qDhaEjfTo470RY6ouqVO
WiY1nzqU+cygeGpGbonmQ3c7gZsd5b7V5IZNnRSWSd8e+TAlSRQ6iXbxHpo1Ex4a4W7XQcIx
hw0cJeqWimBiQJTinoMDRaWjTILk0FYYqdzCH+H4j8I9xSCLLp4qmM+vDr2DhbEwZGHHL6My
FyejWZ8tNoL2FWMBs8iWhczo9dVdz4YcwWtWbr9vtqvZel4G7M9yDQaOgKmjaOLAEFeWsDFH
NbFzG2NRUQtrt3xaiOCIGEBWbk3UCXH5Y53kg+aedCIH3v5wpmrIamzgZ4sUA/ev4WThVknx
HzCiMwar59ZCAbi7QOlPijxF28QBAz95mAEfRDzpGPfmMcuKg3WcKp7xIOdga9JioCekCwBT
wTsttpsNAGIpR30nDMjWus+jb3egCyTihS4AlOdZZ0Ex0Wg8DY/AeVhn72CAjnjRpHp0Ls5O
DJGKyqkpJjE3VtodVsWGEPukYRXRoHtkGoOh7n7xNnWaaDJyXSIc0dWOVvw4S5iL7oYnBFQc
AGVR4Z4ayDv2pRlFbS/gGOE6NC5rkg8RhAFmhYjlzfO///2m1RlDl4pHN3W+0exTGrtoUBzD
KJiq84zQ0x5DiwzYKG35wzbZNwf8DGbfWJUatZCgJXuwTofLgXI6HEKGRylmjPKIN0I7IOUJ
ADe8CyzBc0wcOmcp9mLDJewMzqYQwHX13fa0l1iBlg0A9RcC8PPnS3Qyfbi+P0eWIFDwmXQ0
ATvRUC2ZhOj4dA57ScPbHoHQdih/2oONho0swmY4p1hkZWYdc42bh1SO33+b7cpF8LOy7K/b
zfflSwumnsZF7qMJYkUV2DQ9vkYn8nDdMG2VxD1oDICfQ1l4CuYNxspA1fMUmTpRRUW3V7+i
X6I5+04UmApf5ybREZ2c0ykGNIQWSkxqWWqLqwPz67Vs+j8hcsc2iRJwhOkQBanE+JNo3ig7
Extocn195UYoliH7cjt1AylLj6Q0A8XDoRt7WJ6UmQsjhHJ8oe9If77/8tFPn3y5mn65urCB
JKO3N5d2YAVwYQB9S2/uLg0QkjFPKfczEPPl2k8VU3f8X01uxO3NhdOJLpJh79efLy1dZPqm
h76y7WZe7nabba1ltQkBw1npUKPBxLkYyDR5dDQXlGSYEmuTbm/+7A5CBmCXUwlK3G7PLCFh
YIQ641MC4Be6ZK7m3iKhoUhzYW/azd1Vd5tROdsftuWuleCsttAKyWAkXs0Qco0bc4NIYAv/
M7ZBpljIAVc4GBsrSa6PG9Mxj8zDx+YhCrS/iF8AeUURU975jjAHkQERjolCaLYW1pHatDSM
QB20KCE6rhZQd75zMJx6H4mNUBq91ti6detPOstr7VVkeU9dBwdMyby+brb7OsGdwW1k68Xr
Zrnet6IEygtwcjZkciNfSkk7am/GI309yQhgeW9GuDJ+qhhmXD6c88QA2EVmeginbh/LBBwo
Ue78wpHLBYCeAMxNISS7arSAZWvOAS03HluHpI9e0q2/10c/CWa/cq704fosJXvPbo6p1IYj
ZGTgDBeyKC3GEL10Y08Mlq0/dTCcwbENHEhSxPmQmWRwZgE1NTBEuwEOKbQjt98tWvO1XjkG
4A5bo+gsATiXGbsyuPP64Yv9c+4DVq84RmSAWzkEqlOMHgDi1CyMhQj+rckYtXw4TRhJrW1w
HsFTJqU7rH8a5K7kVB1WMaKSx4JLezlbSsoUrgLQuCfQHuZZMWApjQVRLuRlc7WITYsn0H8J
Iat6uL5umikbl7h1H0wXQviLxH9MUA428NvmFR/EGjcZ8bqMWvjIkKErmHnCMy6UBA8Bocb5
tp3bB3B6V23DRTJE13COoXGlEKgIERe2XlymPDteCrf/UGhWMQZ0eY0cDOkTZinDUNXQEQ4u
yDZ/ldtAzNaz53JVrk8WE2nRtvy/Q7me/wp289kRnLfcVaTauaBTT754KbvM3ay3pUcvmxlm
pwNrmoNydXhpvUySffBSznZwPuvyTA1WB2j6VsI4L+V8Xy5q9nxXbnevs3kZfFuuZ9tfgU0X
7VuZoQFPI2FsxBWFGXdjrSOTpopnbvU6cqBRuEQXXLtnoHCXuodV+Sp7IqvTiTRU83wpquDM
rfceb9l8iHXiChtn2HExPat5BdTOjxPM6WRshIpJwz+4qRUrLP9cwhmE2+WfVVru/Gy5nB+b
A9nfVl6l5GKWZJ4MZ8jGRmSRJ1FvIIImGNf6PKUdPuIQPhFVpab6vj1abld/zbZlAKq5KLfN
9UWTIpEk9KytyqZhrt91to0tDHJEUHzs3aNlYGPlCWIrBnywPQ6DmKkTNHXstwXVYAPql74T
UFrYo2pfEEWFNoNiyPUA1MKduhyzKchT66L63Z1jNC6XEppGdqRtYWWEyUjjeYoGKt42A4Cn
OcDRNzlJaO3QdTbbWtG1jOw7pRqDJa7cdHMxIFPVeddpBUtYTXBMxdkM27EuoemCsKmnYulY
sEC3IapY7uau0wA9Eo+4aPdDQ0oTqXNQZtwEpx6N0T4MTW+cC2QMFEU0UPR5QkspvtzS6X2v
myn/nu0Cvt7tt4eVTc/vfsBNWgT77Wy9w6ECcCNlsIC9Ll/xx5Odf9mX21kQZUMSfK8v4GLz
1xovYbDaLA4vZfAW/dES8HbAb+i7uitf7wGKCzDk/xVsyxdbGtOB/2cWVPnK/tQ0TXnkaB7L
zNF6HijegAfyEelsu3BN4+XfvJ5iT72HHTQccvCWSi3edY0pru803Pl0aCx7p6Kp5kfNagim
1gwgYsbsVC2wfj3s+9znJ9Y0y/v6EsOG7ZHx32WAXdreCl/C3eCQCOZUQAp6MwPPvnVdCWPc
oRCYTLjDPtLIR8PlAdRGwz3I3feHZ4Ifiw7cNjueXHqXMRT+9/jlKU+Sx8681UncUOcB3Ljx
hM7cCScNS3cvWbvbs6y/lsxkwfxlM//ZvVlsPfsGNzOLH7E0BesOACZMpBphNtgib3DKIkPY
vd/AeGWw/1EGs8Viic5/9lKNuvvQCsp5So1KfFa3yuvn2oAZwkC6iFvvDtDSqZI50SbupFsm
J+BCydjzEG2p6CQ8YYalY4I2cWtlPBHSXT1hYqYEcaP5CTE0DqXrxU2DW3YBNGh3cA+oIE52
JPQOWhxe9svvh/XcwuyjGVicTM/ZtUdhgeFxAn4XwlOP3p+54oSGbr1FHqqkBtvlpcf8/u7m
GpCtB63HBt2v5vTWO8SIiSzxPIUCWZj72y+fvORMfJ560qZI1uLjlSehO5h+vLqygNDf+1FT
j4Yg2fCCiNvbj9PCaEouSNF8Su7vp27Vt3R6f/v50z8wfLn1MCg2xOBBuu2fYCEn9TNFT6uG
29nrj+V857JnoRI9fkKz4C05LJYbcI2ntOw7d/EqEWGQLL9tMdzbbg4QTZYnLxltZyuIBQ/f
v4MnCfueJHLvFV/FEgvuQG1duzrfOZmnLpCbwx2VMeVFAnA2YZhk5KTxaIb0XiFrbvH28dUr
pmHztubty11Fu9BmQdWijQ2wPfvxa4cVw0Ey+4VetH+FU5nZGaeU8bFzc0jNE49fQeKQhEOP
WTSPmedC16N6nW0+8aio8Og+g3CFU3eJRsqwSDF0z1Q9y/MBh1NyoXwWElo/uWmq8kZ20JL6
pchgiMD7tGraDJYOEu0J5QSEkz3cXgXRggzyyBn9P6YU3+k9r2T5NOQ689Wj2ZRYFTZ6KmOA
AbyqYGk/tS6W8+1mt/m+D+Jfr+X2/Th4PpQAhB33Gvz+sJNtOztpmYQR17E7JIkhwICICowN
1sH5CqGShKRyemJz5dCSEWK6RMpR3s3VAg3zARCgNR+jpABXfSzAqAvjV+AHqYU+1pj8tdn+
bGW2YKBYh27lQ+JXqbg7dosn+NzcfZCuBrcT6s1h23K/9d3CyrMqdG611MF9K9FYkXT2uV1W
dZYk4clATntLUOVqsy8xLnEZD0w4GAwFab/j62r37OyTCV2rl9+YTrjqpwk1zPP2+NIt4Tx+
LF/fBbvXcr78fkooncwfWb1snqFZb2jXMg62EE7ON6sOrbECWqc/emtYfhBT15hfD7MXGPLi
mIb3hptiucPfvk5TLLeaFmOaOyWVCQxXuunXcxg4NV5EYQub3EGO51iySd9DYz5iDqfQDyiB
0q7uRiUcggHFFH+qzq8Y2J6O2/XRPMM6Jp9jsCDclvQomfgisUj0VRJikVYJ8tkQHdNjyOAE
AlQUI5kSdFo3Xi4MdbIpKW4+pwLDKrebanHheF4uQbIsxuocEYr7e89rmo07KHHnGAX1gDjS
9zNkvdhuloumWCCSVZK70XJI3Dg47cbeVWJggrmfOWb4nT7CHTfw1EDMYNz+weaInARPQKu5
dC9ZJ1y4Iu9TBjjsX8xT8hh2KzzSH0qJFTY1qyNN9rydNdJcraxQtIR4utLU1sRsilAj0lUJ
UyE9xeq2SAo5fL4XRmApVY9Z9x3gfMKpxAJJz8lYWuGtHY/Ihd5fc2ncZ4e56UjfFZ7MfkX2
USN8q/PQjincDrkS7Gz+oxMO6N7TaWU/duVhsbEf3DlOBr2gb3pLA3uYhMrzCYWto3ejB/uX
f9v4tGTPG4YwzAOU0qS/8WP1wo/Z/Gf1qGdbX7fL9f6nzeEsViW48N6TKPylpVWvof3upy5a
fvh0KnYEOI0VED2Ou9aHhu/tVyog/fnPnZ1wfvwA0YV2q9cOnkZu78RS+5EdXLQUWAHTUWI8
ZcxHVpFrU5XKO0BjpIioRnu4vrq5a9oqxbOCaFF4S+exAtDOAFzuyCYFTcWAXwykp8K/KiCZ
pBffhiLXM3TM8GVKVztrOtWqj2a2bhO1RmBuyZMKbTNVYsVqrkursS/4E0ZGdVGCB2giCgBd
Va7vB6qhTjUfVbQBEBSC+rD8dnh+7jw/WzkBzmGp9toxOyQy2q8M/OLOJNcy9RnMahg5+ANk
461lPi4fnEICcuhLv6ZcmKGq4c7x/lzgGvvy20isakcUG4JILj0dViDQFpk4NnRKQYyoHPfL
skmK9bjVR7pZC70h/6UNxp1XrONbMZxukEC8c3itjEE8Wz93EHRky2XyDEbq13s3pkFiEecp
REREu4U9+erMrTY0IgU1hTsgOy7WRceyopw1SrksEUMumZtmyUf1DVl1xPjA3jM/HVnhECPG
Mle9CsrqfCmCt7vX5dpm0f87WB325d8l/FDu5x8+fHjXt6OukLOrHfil1MWn5zolksAKL7Ad
YQh+9gCWJYnwXdc9rIU0cKwGXzK7z7/no5tUazsN5rZhp2/I3YOgRQODAMZYM4YVOBcebo6X
t7r8l3bKPYs52iD+Txz6ku2xiIr78jUVD1WwlxRrxvr+Hr/AdBpR/N7SfkTiFSZy/OO5WCav
wO1HnV91tc4LO5gcv9stlN+H1JIomFJSgQH7o3JYHiiKH1s7eZqmO8rTyunZLahOoiiqDJ2o
PmIAdCFVt87w+LVc1d+WknY/1KHHjtUoLe8giL0efuEorFoTlfTxMnXzcs3I3ntC1oOl9sNm
fItQuR/9ayIy39cT+QCs/yWPUb3A4j9vYIthWNhOA+TphKdh3zt6o4nj7XK9BdYkOGCa5CF7
eLMCPP/7AvX8Pfy43XzQpy+V4IilqOpVTuyW8/fDGrHnttztPvxo1Nrhg43GF4B+KqqcH7bL
/S8XVB2xR0/9BaO54uYRzptpm8gANOmxKDWvG+ShOtUf9lm5UZk9WmlTUn1Fdc4vdtnct6T1
OZzPohow9ziMkCHrl2edjqS6cufdkkapT5faqm20AWm/dMHxrlNrNDdYzqV092spq4suqrKV
b6RRUXz6qNColIIUI6xswV26WRKWeqhYRs5lqyL49P0jFRn+0yTWxSnWKneiCmJDyo1bD4B6
fe+jFOb6KuSRl8wNmGRXTlzR25vOGm5vnA61zZBwygaPnx1dK4o7uXxkIQogl+erB8sx4F4Z
eAd2v9YmfGCH9BRdKvrZkxhDDOCRxDkr+wRaTB1CqhWheQ9PSqlRN5ol4NZSNj+SswXd9rMN
ktnb1lXqenzkoTJmiqWNVydsDblC7AuYtK+eFVy7v2sdHrgj7hZSGLqNsf2XQqTTGIPUo7Dl
2NDApcPL4sSngBw/O+7VpP4/lP7YJfdIAAA=

--9amGYk9869ThD9tj--
