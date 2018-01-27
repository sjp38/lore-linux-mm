Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B9FB6B005D
	for <linux-mm@kvack.org>; Sat, 27 Jan 2018 01:34:28 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id x24so1576689pge.13
        for <linux-mm@kvack.org>; Fri, 26 Jan 2018 22:34:28 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b25si7581698pfc.241.2018.01.26.22.34.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 26 Jan 2018 22:34:24 -0800 (PST)
Subject: Re: Possible deadlock in v4.14.15 contention on shrinker_rwsem in
 shrink_slab()
References: <alpine.LRH.2.11.1801242349220.30642@mail.ewheeler.net>
 <20180125083516.GA22396@dhcp22.suse.cz>
 <alpine.LRH.2.11.1801261846520.7450@mail.ewheeler.net>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <4e9300f9-14c4-84a9-2258-b7e52bb6f753@I-love.SAKURA.ne.jp>
Date: Sat, 27 Jan 2018 15:34:03 +0900
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.11.1801261846520.7450@mail.ewheeler.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Wheeler <linux-mm@lists.ewheeler.net>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Minchan Kim <minchan@kernel.org>, Tejun Heo <tj@kernel.org>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>

On 2018/01/27 4:32, Eric Wheeler wrote:
> On Thu, 25 Jan 2018, Michal Hocko wrote:
> 
>> [CC Kirill, Minchan]
>> On Wed 24-01-18 23:57:42, Eric Wheeler wrote:
>>> Hello all,
>>>
>>> We are getting processes stuck with /proc/pid/stack listing the following:
>>>
>>> [<ffffffffac0cd0d2>] io_schedule+0x12/0x40
>>> [<ffffffffac1b4695>] __lock_page+0x105/0x150
>>> [<ffffffffac1b4dc1>] pagecache_get_page+0x161/0x210
>>> [<ffffffffac1d4ab4>] shmem_unused_huge_shrink+0x334/0x3f0
>>> [<ffffffffac251546>] super_cache_scan+0x176/0x180
>>> [<ffffffffac1cb6c5>] shrink_slab+0x275/0x460
>>> [<ffffffffac1d0b8e>] shrink_node+0x10e/0x320
>>> [<ffffffffac1d0f3d>] node_reclaim+0x19d/0x250
>>> [<ffffffffac1be0aa>] get_page_from_freelist+0x16a/0xac0
>>> [<ffffffffac1bed87>] __alloc_pages_nodemask+0x107/0x290
>>> [<ffffffffac06dbc3>] pte_alloc_one+0x13/0x40
>>> [<ffffffffac1ef329>] __pte_alloc+0x19/0x100
>>> [<ffffffffac1f17b8>] alloc_set_pte+0x468/0x4c0
>>> [<ffffffffac1f184a>] finish_fault+0x3a/0x70
>>> [<ffffffffac1f369a>] __handle_mm_fault+0x94a/0x1190
>>> [<ffffffffac1f3fa4>] handle_mm_fault+0xc4/0x1d0
>>> [<ffffffffac0682a3>] __do_page_fault+0x253/0x4d0
>>> [<ffffffffac068553>] do_page_fault+0x33/0x120
>>> [<ffffffffac8019dc>] page_fault+0x4c/0x60
>>>
>>>
>>> For some reason io_schedule is not coming back,
>>
>> Is this a permanent state or does the holder eventually releases the
>> lock? It smells like somebody hasn't unlocked the shmem page. Tracking
>> those is a major PITA... :/
> 
> Perpetual. It's been locked for a couple days now on two different 
> servers, both running the same 4.14.15 build.
> 
> 
>> Do you remember the last good kernel?
> 
> We were stable on 4.1.y for a long time. The only reason we are updating 
> is because of the Spectre/Meltdown issues.
> 
> I can probably test with 4.9 and let you know if we have the same problem. 
> If you have any ideas on creating an easy way to reproduce the problem, 
> then I can bisect---but bisecting one day at a time will take a long time, 
> and could be prone to bugs which I would like to avoid on this production 
> system.
> 
> Note that we have cherry-picked neither of f80207727aaca3aa nor 
> 0bcac06f27d75285 in our 4.14.15 build.
> 
> Questions:
> 
> 1. Is there a safe way to break this lock so I can migrate the VMs off of 
>    the server?

I don't know there is.

> 
> 2. Would it be useful if I run the `stap` script attached in Tetsuo's 
>    patch?

Thinking from SysRq-t output, I feel that some disk read is stuck.

> 
> 
> 
> == This is our current memory summary on the server, and /proc/meminfo is 
> == at the very bottom of this email:
> ~]#  free -m
>               total        used        free      shared  buff/cache   available
> Mem:          32140        7760        8452         103       15927       22964
> Swap:          9642         764        8877
> ~]# swapon -s
> Filename				Type		Size	Used	Priority
> /dev/zram0                             	partition	9873680	782848	100
> =====================================================
> 
> 
> 
> Below is the output of sysrq-t *without* Tetsuo's patch. I will apply the 
> patch, rebuild, and report back when it happens again.

Since rsyslogd failed to catch portion of SysRq-t output, I can't confirm
whether register_shrinker() was in progress (nor all kernel worker threads
were reported).

----------
tcp_recvmsg+0x586/0x9a0
journal: Missed 244 kernel messages
ret_from_fork+0x35/0x40
journal: Missed 2304 kernel messages
? kmem_cache_alloc+0xd2/0x1a0
journal: Missed 319 kernel messages
drbd7916_a_rt.e S    0  4989      2 0x80000080
journal: Missed 198 kernel messages
kernel_recvmsg+0x52/0x70
journal: Missed 1301 kernel messages
? handle_mm_fault+0xc4/0x1d0
journal: Missed 255 kernel messages
? vhost_dev_ioctl+0x3f0/0x3f0
journal: Missed 293 kernel messages
wait_woken+0x64/0x80
journal: Missed 197 kernel messages
ret_from_fork+0x35/0x40
journal: Missed 26 kernel messages
? drbd_destroy_connection+0x160/0x160 [drbd]
journal: Missed 17 kernel messages
? __schedule+0x1dc/0x770
journal: Missed 18 kernel messages
ret_from_fork+0x35/0x40
journal: Missed 27 kernel messages
kthread+0xfc/0x130
----------

But what I was surprised is number of kernel worker threads.
"grep ^kworker/ | sort" matched 314 threads and "grep ^kworker/0:"
matched 244.

----------
kworker/0:0     I    0 21214      2 0x80000080
kworker/0:0H    I    0     4      2 0x80000000
kworker/0:1     I    0 21215      2 0x80000080
kworker/0:10    I    0 10340      2 0x80000080
kworker/0:100   I    0 21282      2 0x80000080
kworker/0:101   I    0 21283      2 0x80000080
kworker/0:102   I    0 23765      2 0x80000080
kworker/0:103   I    0 18598      2 0x80000080
kworker/0:104   I    0 21284      2 0x80000080
kworker/0:105   I    0 21285      2 0x80000080
kworker/0:106   I    0 21286      2 0x80000080
kworker/0:107   I    0 21287      2 0x80000080
kworker/0:108   I    0 21288      2 0x80000080
kworker/0:109   I    0 10382      2 0x80000080
kworker/0:11    I    0 10341      2 0x80000080
kworker/0:110   I    0 21289      2 0x80000080
kworker/0:111   I    0 21290      2 0x80000080
kworker/0:112   I    0 10383      2 0x80000080
kworker/0:113   I    0 21292      2 0x80000080
kworker/0:114   I    0 16684      2 0x80000080
kworker/0:115   I    0 21293      2 0x80000080
kworker/0:116   I    0 10384      2 0x80000080
kworker/0:117   I    0 10385      2 0x80000080
kworker/0:118   I    0 31163      2 0x80000080
kworker/0:119   I    0 21295      2 0x80000080
kworker/0:12    I    0 16573      2 0x80000080
kworker/0:120   I    0 18612      2 0x80000080
kworker/0:121   I    0  3835      2 0x80000080
kworker/0:122   I    0  3836      2 0x80000080
kworker/0:123   I    0 10386      2 0x80000080
kworker/0:124   I    0 21297      2 0x80000080
kworker/0:125   I    0 10387      2 0x80000080
kworker/0:126   I    0 10388      2 0x80000080
kworker/0:127   I    0 23691      2 0x80000080
kworker/0:128   I    0  3839      2 0x80000080
kworker/0:129   I    0 10390      2 0x80000080
kworker/0:13    I    0 21221      2 0x80000080
kworker/0:130   I    0  3841      2 0x80000080
kworker/0:131   I    0 10391      2 0x80000080
kworker/0:132   I    0 21301      2 0x80000080
kworker/0:133   I    0  3843      2 0x80000080
kworker/0:134   I    0 21302      2 0x80000080
kworker/0:135   I    0  3844      2 0x80000080
kworker/0:136   I    0 10392      2 0x80000080
kworker/0:137   I    0 10393      2 0x80000080
kworker/0:138   I    0 21305      2 0x80000080
kworker/0:139   I    0 10394      2 0x80000080
kworker/0:14    I    0 10342      2 0x80000080
kworker/0:140   I    0 21307      2 0x80000080
kworker/0:141   I    0 10395      2 0x80000080
kworker/0:142   I    0 10396      2 0x80000080
kworker/0:143   I    0 10397      2 0x80000080
kworker/0:144   I    0 10398      2 0x80000080
kworker/0:145   I    0  3850      2 0x80000080
kworker/0:146   I    0 23798      2 0x80000080
kworker/0:147   I    0 21311      2 0x80000080
kworker/0:148   I    0 26926      2 0x80000080
kworker/0:149   I    0 10399      2 0x80000080
kworker/0:15    I    0 10343      2 0x80000080
kworker/0:150   I    0 10400      2 0x80000080
kworker/0:151   I    0 10401      2 0x80000080
kworker/0:152   I    0 10403      2 0x80000080
kworker/0:153   I    0  3854      2 0x80000080
kworker/0:154   I    0 26931      2 0x80000080
kworker/0:155   I    0 21315      2 0x80000080
kworker/0:156   I    0 10404      2 0x80000080
kworker/0:157   I    0 21317      2 0x80000080
kworker/0:158   I    0 10405      2 0x80000080
kworker/0:159   I    0 21319      2 0x80000080
kworker/0:16    I    0 18530      2 0x80000080
kworker/0:160   I    0 21320      2 0x80000080
kworker/0:161   I    0 21321      2 0x80000080
kworker/0:162   I    0 21322      2 0x80000080
kworker/0:163   I    0 10406      2 0x80000080
kworker/0:164   I    0 21323      2 0x80000080
kworker/0:165   I    0 10407      2 0x80000080
kworker/0:166   I    0 10408      2 0x80000080
kworker/0:167   I    0 10409      2 0x80000080
kworker/0:168   I    0 22590      2 0x80000080
kworker/0:169   I    0 10410      2 0x80000080
kworker/0:17    I    0 10838      2 0x80000080
kworker/0:170   I    0 10411      2 0x80000080
kworker/0:171   I    0 10412      2 0x80000080
kworker/0:172   I    0  3866      2 0x80000080
kworker/0:173   I    0 10413      2 0x80000080
kworker/0:174   I    0 23709      2 0x80000080
kworker/0:175   I    0 21329      2 0x80000080
kworker/0:176   I    0 21330      2 0x80000080
kworker/0:177   I    0 21331      2 0x80000080
kworker/0:178   I    0  3869      2 0x80000080
kworker/0:179   I    0 10414      2 0x80000080
kworker/0:18    I    0 18531      2 0x80000080
kworker/0:180   I    0 10415      2 0x80000080
kworker/0:181   I    0 21333      2 0x80000080
kworker/0:182   I    0 23715      2 0x80000080
kworker/0:183   I    0 10416      2 0x80000080
kworker/0:184   I    0 10417      2 0x80000080
kworker/0:185   I    0  3872      2 0x80000080
kworker/0:186   I    0  3873      2 0x80000080
kworker/0:187   I    0 10418      2 0x80000080
kworker/0:188   I    0 21337      2 0x80000080
kworker/0:189   I    0 21338      2 0x80000080
kworker/0:19    I    0 21223      2 0x80000080
kworker/0:190   I    0 10419      2 0x80000080
kworker/0:191   I    0 10420      2 0x80000080
kworker/0:192   I    0 10421      2 0x80000080
kworker/0:193   I    0 21340      2 0x80000080
kworker/0:194   I    0 10422      2 0x80000080
kworker/0:195   I    0  3877      2 0x80000080
kworker/0:196   I    0 10423      2 0x80000080
kworker/0:197   I    0 21342      2 0x80000080
kworker/0:198   I    0 10424      2 0x80000080
kworker/0:199   I    0  3881      2 0x80000080
kworker/0:1H    I    0   457      2 0x80000000
kworker/0:2     I    0  7149      2 0x80000080
kworker/0:20    I    0 10344      2 0x80000080
kworker/0:200   I    0  3882      2 0x80000080
kworker/0:201   I    0 21344      2 0x80000080
kworker/0:202   I    0 21345      2 0x80000080
kworker/0:203   I    0 10425      2 0x80000080
kworker/0:204   I    0 10426      2 0x80000080
kworker/0:205   I    0 10428      2 0x80000080
kworker/0:206   I    0  3887      2 0x80000080
kworker/0:207   I    0 10429      2 0x80000080
kworker/0:208   I    0 10430      2 0x80000080
kworker/0:209   I    0 10431      2 0x80000080
kworker/0:21    I    0 18533      2 0x80000080
kworker/0:210   I    0 10432      2 0x80000080
kworker/0:211   I    0  3890      2 0x80000080
kworker/0:212   I    0 10433      2 0x80000080
kworker/0:213   I    0 10434      2 0x80000080
kworker/0:214   I    0 10435      2 0x80000080
kworker/0:215   I    0 21352      2 0x80000080
kworker/0:216   I    0 10436      2 0x80000080
kworker/0:217   I    0 10437      2 0x80000080
kworker/0:218   I    0 21354      2 0x80000080
kworker/0:219   I    0 10439      2 0x80000080
kworker/0:22    I    0 10346      2 0x80000080
kworker/0:220   I    0 10440      2 0x80000080
kworker/0:221   I    0 21356      2 0x80000080
kworker/0:222   I    0 10441      2 0x80000080
kworker/0:223   I    0 21358      2 0x80000080
kworker/0:224   I    0  2432      2 0x80000080
kworker/0:225   I    0  2433      2 0x80000080
kworker/0:226   I    0  2434      2 0x80000080
kworker/0:227   I    0  2435      2 0x80000080
kworker/0:229   I    0  2437      2 0x80000080
kworker/0:23    I    0 21225      2 0x80000080
kworker/0:231   I    0  2439      2 0x80000080
kworker/0:232   I    0  2440      2 0x80000080
kworker/0:234   I    0 22654      2 0x80000080
kworker/0:236   I    0  2444      2 0x80000080
kworker/0:237   I    0  3909      2 0x80000080
kworker/0:24    I    0 21226      2 0x80000080
kworker/0:241   I    0  3913      2 0x80000080
kworker/0:244   I    0  3916      2 0x80000080
kworker/0:245   I    0  2449      2 0x80000080
kworker/0:246   I    0  2450      2 0x80000080
kworker/0:247   I    0 18632      2 0x80000080
kworker/0:25    I    0 21227      2 0x80000080
kworker/0:250   I    0  2453      2 0x80000080
kworker/0:253   I    0  2455      2 0x80000080
kworker/0:26    I    0 21228      2 0x80000080
kworker/0:262   I    0 31402      2 0x80000080
kworker/0:27    I    0 10347      2 0x80000080
kworker/0:28    I    0 21230      2 0x80000080
kworker/0:29    I    0 18538      2 0x80000080
kworker/0:3     I    0 21216      2 0x80000080
kworker/0:30    I    0 10348      2 0x80000080
kworker/0:31    I    0 18540      2 0x80000080
kworker/0:32    R  running task        0 18541      2 0x80000080
kworker/0:33    I    0 10349      2 0x80000080
kworker/0:34    I    0 10350      2 0x80000080
kworker/0:35    I    0 10351      2 0x80000080
kworker/0:36    I    0 21234      2 0x80000080
kworker/0:37    I    0 18544      2 0x80000080
kworker/0:38    I    0 10352      2 0x80000080
kworker/0:39    I    0 10353      2 0x80000080
kworker/0:4     I    0 18521      2 0x80000080
kworker/0:40    I    0 21236      2 0x80000080
kworker/0:41    I    0 10354      2 0x80000080
kworker/0:42    I    0 18549      2 0x80000080
kworker/0:43    I    0 21237      2 0x80000080
kworker/0:44    I    0 10355      2 0x80000080
kworker/0:45    I    0 10356      2 0x80000080
kworker/0:46    I    0 10357      2 0x80000080
kworker/0:47    I    0 21241      2 0x80000080
kworker/0:48    I    0 21242      2 0x80000080
kworker/0:49    I    0 18554      2 0x80000080
kworker/0:5     I    0 18522      2 0x80000080
kworker/0:50    I    0 23141      2 0x80000080
kworker/0:51    I    0 10358      2 0x80000080
kworker/0:52    I    0 16589      2 0x80000080
kworker/0:53    I    0 18556      2 0x80000080
kworker/0:54    I    0 18557      2 0x80000080
kworker/0:55    I    0 21244      2 0x80000080
kworker/0:56    I    0 18558      2 0x80000080
kworker/0:57    I    0 23146      2 0x80000080
kworker/0:58    I    0 18559      2 0x80000080
kworker/0:59    I    0 21245      2 0x80000080
kworker/0:6     I    0 21217      2 0x80000080
kworker/0:60    I    0 21250      2 0x80000080
kworker/0:61    I    0 18561      2 0x80000080
kworker/0:62    I    0 10359      2 0x80000080
kworker/0:63    I    0 10360      2 0x80000080
kworker/0:64    I    0 21253      2 0x80000080
kworker/0:65    I    0 21254      2 0x80000080
kworker/0:66    I    0 21255      2 0x80000080
kworker/0:67    I    0 10361      2 0x80000080
kworker/0:68    I    0 21257      2 0x80000080
kworker/0:69    I    0 21258      2 0x80000080
kworker/0:7     I    0 10339      2 0x80000080
kworker/0:70    I    0 18570      2 0x80000080
kworker/0:71    I    0 10362      2 0x80000080
kworker/0:72    I    0 10363      2 0x80000080
kworker/0:73    I    0 21261      2 0x80000080
kworker/0:74    I    0 10365      2 0x80000080
kworker/0:75    I    0 10366      2 0x80000080
kworker/0:76    I    0 21264      2 0x80000080
kworker/0:77    I    0 21265      2 0x80000080
kworker/0:78    I    0 10367      2 0x80000080
kworker/0:79    I    0 10368      2 0x80000080
kworker/0:8     I    0 18525      2 0x80000080
kworker/0:80    I    0 10369      2 0x80000080
kworker/0:81    I    0 10370      2 0x80000080
kworker/0:82    I    0 10371      2 0x80000080
kworker/0:83    I    0 21270      2 0x80000080
kworker/0:84    I    0 10372      2 0x80000080
kworker/0:85    I    0 10373      2 0x80000080
kworker/0:86    I    0 18584      2 0x80000080
kworker/0:87    I    0 10374      2 0x80000080
kworker/0:88    I    0 10375      2 0x80000080
kworker/0:89    I    0 21274      2 0x80000080
kworker/0:9     I    0 18526      2 0x80000080
kworker/0:90    I    0 10376      2 0x80000080
kworker/0:91    I    0 10377      2 0x80000080
kworker/0:92    I    0 10378      2 0x80000080
kworker/0:93    I    0 10379      2 0x80000080
kworker/0:94    I    0 10380      2 0x80000080
kworker/0:95    I    0 10381      2 0x80000080
kworker/0:96    I    0 18593      2 0x80000080
kworker/0:97    I    0 21280      2 0x80000080
kworker/0:98    I    0 23179      2 0x80000080
kworker/0:99    I    0 21281      2 0x80000080
kworker/1:0     I    0 24108      2 0x80000080
kworker/1:0H    I    0    18      2 0x80000000
kworker/1:1     I    0 24109      2 0x80000080
kworker/1:10    I    0 24118      2 0x80000080
kworker/1:11    I    0 24119      2 0x80000080
kworker/1:12    I    0 24120      2 0x80000080
kworker/1:13    I    0 24121      2 0x80000080
kworker/1:14    I    0 24122      2 0x80000080
kworker/1:15    I    0 24123      2 0x80000080
kworker/1:16    I    0 24124      2 0x80000080
kworker/1:17    I    0 24125      2 0x80000080
kworker/1:18    I    0 24126      2 0x80000080
kworker/1:19    I    0 24127      2 0x80000080
kworker/1:1H    I    0   550      2 0x80000000
kworker/1:2     I    0 24110      2 0x80000080
kworker/1:20    I    0 24128      2 0x80000080
kworker/1:21    I    0 24129      2 0x80000080
kworker/1:22    I    0 24130      2 0x80000080
kworker/1:23    I    0 24131      2 0x80000080
kworker/1:24    I    0 24132      2 0x80000080
kworker/1:25    I    0 24133      2 0x80000080
kworker/1:26    I    0  5787      2 0x80000080
kworker/1:27    I    0  5788      2 0x80000080
kworker/1:28    I    0 24134      2 0x80000080
kworker/1:29    I    0 24135      2 0x80000080
kworker/1:3     I    0 24111      2 0x80000080
kworker/1:4     I    0 24112      2 0x80000080
kworker/1:5     I    0 24113      2 0x80000080
kworker/1:6     I    0 24114      2 0x80000080
kworker/1:7     I    0 24115      2 0x80000080
kworker/1:8     I    0 24116      2 0x80000080
kworker/1:9     I    0 24117      2 0x80000080
kworker/2:0     I    0  9749      2 0x80000080
kworker/2:0H    I    0    24      2 0x80000000
kworker/2:1     I    0  9750      2 0x80000080
kworker/2:1H    I    0   591      2 0x80000000
kworker/2:2     I    0  9751      2 0x80000080
kworker/2:68    I    0 30993      2 0x80000080
kworker/2:69    I    0 30995      2 0x80000080
kworker/3:0     I    0 31071      2 0x80000080
kworker/3:0H    I    0    30      2 0x80000000
kworker/3:1H    I    0   455      2 0x80000000
kworker/3:2     I    0  1299      2 0x80000080
kworker/3:3     I    0  4367      2 0x80000080
kworker/3:69    I    0 13343      2 0x80000080
kworker/3:70    R  running task        0 13344      2 0x80000080
kworker/4:0     I    0  7454      2 0x80000080
kworker/4:0H    I    0    36      2 0x80000000
kworker/4:1H    I    0   456      2 0x80000000
kworker/4:8     I    0 23606      2 0x80000080
kworker/4:9     I    0 23607      2 0x80000080
kworker/5:0     I    0  7434      2 0x80000080
kworker/5:0H    I    0    42      2 0x80000000
kworker/5:1     I    0 21046      2 0x80000080
kworker/5:1H    I    0   454      2 0x80000000
kworker/5:3     I    0 22704      2 0x80000080
kworker/5:37    I    0 31097      2 0x80000080
kworker/6:0     I    0  4395      2 0x80000080
kworker/6:0H    I    0    48      2 0x80000000
kworker/6:10    I    0  6159      2 0x80000080
kworker/6:1H    I    0   553      2 0x80000000
kworker/7:0H    I    0    54      2 0x80000000
kworker/7:1H    I    0   549      2 0x80000000
kworker/7:2     I    0 22741      2 0x80000080
kworker/7:3     I    0 22742      2 0x80000080
kworker/7:5     I    0 22744      2 0x80000080
kworker/u16:0   I    0 14713      2 0x80000080
kworker/u16:1   D    0  9752      2 0x80000080
kworker/u16:2   I    0  3153      2 0x80000080
kworker/u16:3   I    0 28108      2 0x80000080
----------

Although most of them were idle, and the system had enough free memory
for creating workqueues, is there possibility that waiting for a work
item to complete get stuck due to workqueue availability?
( Was there no "Showing busy workqueues and worker pools:" line?
http://lkml.kernel.org/r/20170502041235.zqmywvj5tiiom3jk@merlins.org had it. )

----------
kworker/0:262   I    0 31402      2 0x80000080
Call Trace:
? __schedule+0x1dc/0x770
? cached_dev_write_complete+0x2c/0x60 [bcache]
schedule+0x32/0x80
worker_thread+0xc3/0x3e0
kthread+0xfc/0x130
? rescuer_thread+0x380/0x380
? kthread_park+0x60/0x60
ret_from_fork+0x35/0x40
----------

> ~]# cat /proc/meminfo 
> MemTotal:       32912276 kB
> MemFree:         8646212 kB
> MemAvailable:   23506448 kB
> Buffers:          230592 kB
> Cached:         15443124 kB
> SwapCached:         6112 kB
> Active:         14235496 kB
> Inactive:        7679336 kB
> Active(anon):    3723980 kB
> Inactive(anon):  2634188 kB
> Active(file):   10511516 kB
> Inactive(file):  5045148 kB
> Unevictable:      233704 kB
> Mlocked:          233704 kB
> SwapTotal:       9873680 kB
> SwapFree:        9090832 kB
> Dirty:                40 kB
> Writeback:             0 kB
> AnonPages:       6435292 kB
> Mapped:           162024 kB
> Shmem:            105880 kB
> Slab:             635280 kB
> SReclaimable:     311468 kB
> SUnreclaim:       323812 kB
> KernelStack:       25296 kB
> PageTables:        31376 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:    26329816 kB
> Committed_AS:   16595004 kB
> VmallocTotal:   34359738367 kB
> VmallocUsed:           0 kB
> VmallocChunk:          0 kB
> HardwareCorrupted:     0 kB
> AnonHugePages:   6090752 kB
> ShmemHugePages:        0 kB
> ShmemPmdMapped:        0 kB
> CmaTotal:              0 kB
> CmaFree:               0 kB
> HugePages_Total:       0
> HugePages_Free:        0
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:       2048 kB
> DirectMap4k:     1012624 kB
> DirectMap2M:    32514048 kB

One of workqueue threads was waiting at

----------
static void *new_read(struct dm_bufio_client *c, sector_t block,
		      enum new_flag nf, struct dm_buffer **bp)
{
	int need_submit;
	struct dm_buffer *b;

	LIST_HEAD(write_list);

	dm_bufio_lock(c);
	b = __bufio_new(c, block, nf, &need_submit, &write_list);
#ifdef CONFIG_DM_DEBUG_BLOCK_STACK_TRACING
	if (b && b->hold_count == 1)
		buffer_record_stack(b);
#endif
	dm_bufio_unlock(c);

	__flush_write_list(&write_list);

	if (!b)
		return NULL;

	if (need_submit)
		submit_io(b, READ, read_endio);

	wait_on_bit_io(&b->state, B_READING, TASK_UNINTERRUPTIBLE); // <= here

	if (b->read_error) {
		int error = blk_status_to_errno(b->read_error);

		dm_bufio_release(b);

		return ERR_PTR(error);
	}

	*bp = b;

	return b->data;
}
----------

but what are possible reasons? Does this request depend on workqueue availability?

----------
kworker/0:32    R  running task        0 18541      2 0x80000080
Call Trace:
? __schedule+0x1dc/0x770
schedule+0x32/0x80
worker_thread+0xc3/0x3e0
kthread+0xfc/0x130
? rescuer_thread+0x380/0x380
? kthread_park+0x60/0x60
ret_from_fork+0x35/0x40

kworker/3:70    R  running task        0 13344      2 0x80000080
Workqueue: events_power_efficient fb_flashcursor
Call Trace:
? fb_flashcursor+0x131/0x140
? bit_clear+0x110/0x110
? process_one_work+0x141/0x340
? worker_thread+0x47/0x3e0
? kthread+0xfc/0x130
? rescuer_thread+0x380/0x380
? kthread_park+0x60/0x60
? ret_from_fork+0x35/0x40

kworker/u16:1   D    0  9752      2 0x80000080
Workqueue: dm-thin do_worker [dm_thin_pool]
Call Trace:
? __schedule+0x1dc/0x770
? out_of_line_wait_on_atomic_t+0x110/0x110
schedule+0x32/0x80
io_schedule+0x12/0x40
bit_wait_io+0xd/0x50
__wait_on_bit+0x5a/0x90
out_of_line_wait_on_bit+0x8e/0xb0
? bit_waitqueue+0x30/0x30
new_read+0x9f/0x100 [dm_bufio]
dm_bm_read_lock+0x21/0x70 [dm_persistent_data]
ro_step+0x31/0x60 [dm_persistent_data]
btree_lookup_raw.constprop.7+0x3a/0x100 [dm_persistent_data]
dm_btree_lookup+0x71/0x100 [dm_persistent_data]
__find_block+0x55/0xa0 [dm_thin_pool]
dm_thin_find_block+0x48/0x70 [dm_thin_pool]
process_cell+0x67/0x510 [dm_thin_pool]
? dm_bio_detain+0x4c/0x60 [dm_bio_prison]
process_bio+0xaa/0xc0 [dm_thin_pool]
do_worker+0x632/0x8b0 [dm_thin_pool]
? __switch_to+0xa8/0x480
process_one_work+0x141/0x340
worker_thread+0x47/0x3e0
kthread+0xfc/0x130
? rescuer_thread+0x380/0x380
? kthread_park+0x60/0x60
? SyS_exit_group+0x10/0x10
ret_from_fork+0x35/0x40
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
