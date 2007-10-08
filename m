Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id l98GpvM7001247
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 02:51:57 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l98GtWt4283222
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 02:55:33 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l98GpfA5013098
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 02:51:41 +1000
Message-ID: <470A6010.6000108@linux.vnet.ibm.com>
Date: Mon, 08 Oct 2007 22:21:28 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: VMA lookup with RCU
References: <46F01289.7040106@linux.vnet.ibm.com> <470509F5.4010902@linux.vnet.ibm.com> <1191518486.5574.24.camel@lappy> <200710071747.23252.nickpiggin@yahoo.com.au> <1191829915.22357.95.camel@twins> <4709F92C.80207@linux.vnet.ibm.com>
In-Reply-To: <4709F92C.80207@linux.vnet.ibm.com>
Content-Type: multipart/mixed;
 boundary="------------050209080604000903020002"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Peter Zijlstra <peterz@infradead.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Alexis Bruemmer <alexisb@us.ibm.com>, Balbir Singh <balbir@in.ibm.com>, Badari Pulavarty <pbadari@us.ibm.com>, Max Asbock <amax@us.ibm.com>, linux-mm <linux-mm@kvack.org>, Bharata B Rao <bharata@in.ibm.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------050209080604000903020002
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit



>> Apparently our IBM friends on this thread have a workload where mmap_sem
>> does hurt, and I suspect its a massively threaded Java app on a somewhat
>> larger box (8-16 cpus), which does a bit of faulting around.
>>
>> But I'll let them tell about it :-)
>>
> 
> Nick,
> 
> We used the latest glibc (with the private futexes fix) and the latest
> kernel. We see improvements in scalability, but at 12-16 CPU's, we see
> a slowdown. Vaidy has been using ebizzy for testing mmap_sem
> scalability.
> 

Hi Peter and Nick,

We have been doing some tests with ebizzy 0.2 workload.
Here are some of the test results...

ebizzy-futex.png plots the performance impact of private futex while
ebizzy-rcu-vma.png plots the performance of Peter's RCU VMA look patch
against base kernel with and without private futex.

We can observe in both the plots that private futex improved scaling
significantly from 4 CPUs to 8 CPUs but we still have scaling issues beyond
12 CPUs.

Peter's RCU based b+tree vma lookup approach gives marginal performance
improvement till 4 to 8 CPUs but does not help beyond that.

Perhaps the scaling problem area shifts beyond 8-12 cpus and it is not just
the mmap_sem and vma lookup.

The significant oprofile output for various configurations are listed below:

12 CPUs 2.6.23-rc6 No private futex:

samples  %        symbol name
6908330  23.7520  __down_read
4990895  17.1595  __up_read
2165162   7.4442  find_vma
2069868   7.1166  futex_wait
2063447   7.0945  futex_wake
1557829   5.3561  drop_futex_key_refs
741268    2.5486  task_rq_lock
638947    2.1968  schedule
600493    2.0646  system_call
515924    1.7738  copy_user_generic_unrolled
399672    1.3741  mwait_idle

12 CPUs 2.6.23-rc6 with private futex:

samples  %        symbol name
2095531  15.5092  task_rq_lock
1094271   8.0988  schedule
1068093   7.9050  futex_wake
516250    3.8208  futex_wait
469220    3.4727  mwait_idle
468979    3.4710  system_call
443208    3.2802  idle_cpu
438301    3.2439  update_curr
397231    2.9399  try_to_wake_up
364424    2.6971  apic_timer_interrupt
362633    2.6839  scheduler_tick

8 CPUs 2.6.23-rc9 + RCU VMA + private futex:

samples  %        symbol name
386111   10.4460  mwait_idle
367289    9.9368  __btree_search
286286    7.7453  apic_timer_interrupt
272863    7.3821  find_busiest_group
230268    6.2298  scheduler_tick
224902    6.0846  copy_user_generic_unrolled
188991    5.1130  memset
123692    3.3464  __exit_idle
91930     2.4871  hrtimer_run_queues
87796     2.3753  task_rq_lock
85968     2.3258  run_rebalance_domains

12 CPUs 2.6.23-rc9 + RCU VMA + private futex:

samples  %        symbol name
14505427 18.6891  task_rq_lock
10323001 13.3004  futex_wake
6980246   8.9935  schedule
4768884   6.1443  futex_wait
2981997   3.8421  idle_cpu
2939439   3.7872  system_call
2655022   3.4208  update_curr
2433540   3.1354  try_to_wake_up
1786021   2.3011  check_preempt_curr_fair
1692711   2.1809  syscall_trace_enter
1486381   1.9151  thread_return

All the above test results has the impact of oprofile included.  Running
oprofile also may significantly increase mmap_sem contention.

I Will run the tests again without oprofile to understand the impact of
oprofile itself.

Please let me know your comments and suggestions.

--Vaidy

--------------050209080604000903020002
Content-Type: image/png;
 name="ebizzy-futex.png"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="ebizzy-futex.png"

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
/WGrdoD0h0BygNt/Rl0+CP0hlBrglBog/WErMcApbQWkP+zobIKnYEE8RX/YknZz8uDNn4WP
+aU/7NQMkP5wUDFA+sNR6k5IsPkWDUJ/iKh3IPr3/i4YT7UA6Q8x1h9QicERIEwRIEwRIEwR
IEwRIEwRIEwRIEwRIEwRIEwRIEwRIEwRIEwRIEwRIEwRIEwRIEwRIEwRIEwRIEwRIEwRIEwR
IEwRIEwRIEwRIEwRIEwRIEwRIEwRIEwRIEwRIEwRIEwRIEwRIEwRIEwRIEwRIEwRIEwRIEwR
IEwRIEwRIEwRIEwRIEwRIEy5ClBpHKZTYRjr6Wz/wfRenlOhcZhOgWHe9a0F9vGcSo3DdAoM
Q4DVh2E6wcOm12YbPAGpUgOcXqmPBbKFm2CgMgKErfStNwAAAAAAbdPaJ9bbt1YZR2k6OsP8
jZE9ltIw6w84byCd6WgdFdQ7uqj2K1cYR2eYv2eUPZbSMOsPOO8nrfasnAWoueaoDJM91PfM
Z+5YSsO8lhOxeT/pzXSyhJcmZI+lMYbOMO42wfk/aaVN57Lt1NgEZ/+g9S5N8LTp9LUJXn5V
Ki+68n/QaptyjWEUN50Kg7xyLvMJx3EYoNarfqXpaOw++AlQ8fQyAd4NozGd4A9508neBmu9
WFJ85a8wiJth5h9N5ljfYbJ/0JsBsnZCdJ4VAAAAAAAAAAAAxsMZJhR2eR5d7So14MTlBXrU
h9LmAMPrOaYpctXTeuHHtK6cXAeCLMv1Tdvcvn/bR7lskw//ARJ936QRDTBMa3P53OYB1Ics
uQGSILJEN6WnAc4XI588DngqvjNxuROy/o2dEFRHbzBFgIB3/wF9QSvj9nQsCQAAAABJRU5E
rkJggg==
--------------050209080604000903020002
Content-Type: image/png;
 name="ebizzy-rcu-vma.png"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="ebizzy-rcu-vma.png"

iVBORw0KGgoAAAANSUhEUgAAAoAAAAHgCAMAAAACDyzWAAABKVBMVEX///8AAACgoKD/AAAA
wAAAgP/AAP8A7u7AQADu7gAgIMD/wCAAgECggP+AQAD/gP8AwGAAwMAAYIDAYIAAgABA/4Aw
YICAYABAQEBAgAAAAICAYBCAYGCAYIAAAMAAAP8AYADjsMBAwIBgoMBgwABgwKCAAACAAIBg
IIBgYGAgICAgQEAgQIBggCBggGBggICAgEAggCCAgICgoKCg0ODAICAAgIDAYACAwODAYMDA
gADAgGD/QAD/QECAwP//gGD/gIDAoADAwMDA/8D/AAD/AP//gKDAwKD/YGAA/wD/gAD/oACA
4OCg4OCg/yDAAADAAMCgICCgIP+AIACAICCAQCCAQICAYMCAYP+AgADAwAD/gED/oED/oGD/
oHD/wMD//wD//4D//8BUJrxzAAARx0lEQVR4nO2dgZKjKhAAtfZt/v+T32UTFRQVYWAG6K66
22yiI4m9M4hopgkAAAAAAAAAAAAAAAAAAAAAAHpjnuOXjF70bhvrE8khoVXm2RcppEBQi39P
Os8/MgcBYeW9y+92+5mAd4tEx8O7cfkKuCTC5f/l3/L/97XZXzG0+nyQ+hjl4rVliXn7gaA9
M++c8QT0HvomrMoEFjk6sz25j+I/ua/FCNg9jmfbAzcDOnbtctc0HQXcMpq7iflcQD/LLa/s
7EfAfgkKuCulm2uHFcOLHEy9yoBOFD9MKPFCb0QKeKyFBwHjymxECd41aX+cDl3h7+21zDol
dXIPDgIrHhc5qOqW2YuDkP3Rx7okAoIqCAh6UIEBAAAAAAAAAAAAAAA6ZzcbDqA+CAia4B+o
sp/iBpCCgH+TVC4UikNzKoRRbw4CVg5Dc/z13BU7eU+F4tCcEmEQsHYYmlM4CAwJAoIqCAjT
8RrTwG9XQyYZwykICPtLl6+vlr9d/eGm01YrEAT0CN4h5Pja7i42k3vpffKm01cVDgK6HO3y
X1tc+/u5v8GIu8LPHX5okbZLBAFNXIP2SW19bfZuUzh5mZESDBn4w7r7m9mcPkJAEMG/G9jp
3bmCAt4coNxuOr3VwkFAj2Veij/i4vX6/KEW92Zx0+61h5vObLpcEDDA8QC4+BbNBIEhQUBQ
BQFBFQSER8zuCIxAJxEB+0d2pgECwjOkZhoEbpGOgHCP1EwDb7ltCcYB4Z78mQbzJtsWMZhA
/7vD37rI25MIAsWQmGlwJ2By29JXFQ4CpRCaaXB8GgEhAqmZBtcCMhkBThCdabBW6e3HfpGH
rUtcTz4IlKb+TIMIEBBUQUBQBQFBFQQEVRCwK2TnHdQAAXtCeN5BDRCwJwTmHbiD1MHX3GDL
WRDGAWEla97B/pTw7WvrJrYt/d7hN0nkPUsEAQmy5h1Mu9Mc7muXAh5Vj29w2moFgoAAefMO
1ocn5353p+Q4Fww7VgvcqQJHn4ICzvt5ByevLSsiIBwQnndweM2r59NmMyUYfI4HwFZBQFAF
AUEVBARVEBAe4Q08C3QuEbAdbMw0QMBRCZ6N9X+7GpDzB/kSt79bHQFHIjiEfHzNXUR0poEX
fw5ESXtXievJB4EIjnb5r5WbaTBvsm0tCSbe1x1+q0U+FokgcIvmTIM7AZPfU/qqwkHgDm8/
7wQM1eZjp80twftFvMWcurzvOyLgqKy72d33RzmCAh5EOnltWfG5gKkSImAzmJhpsFbp7cc+
9MN3lbqe924Sg0AS/s5+tusPt0fTJjVx+rleqjVQkkU+UxJmCJgdBOqxl86MhMkC+h0KmbM8
UIQz2dQdzPCGEtwIN5lOPxEiYL9E2qUrIQL2yUOr9BxkGKY/0lKaUiJkILov8jRSkBAB+0FG
n8oOImAfiOaumokQAdvniS+H+XgSQXNAwKY5fvXVKdtk0EgF61RjBGyWaPeO85Bj02CFRIiA
TRLpRWAK/PaS9MbSQMDmiPLhQr1tkWcbfbD0AxCwKSLki1DPWVR22wkgYDPcCvBAPWcd2TY8
BgGb4GbHp6jnrPu4LWlbCoKA5rmUL0c9J8jDFQQTIQKa5mJPi6jnBHu6ipCECGiW0z0sqp4T
9fk6Ag4ioElO5Cuj3hY9YaXcRIiA1gifXSurnrOVlNVyJERAS4T2ZB31nM2lrZfqIAJa4Shf
ZfWczaatmJQIEdAC+12npJ6z/dQ1H0uIgNr4u0xbva0d6es+chABNXHls6LeQlZj4hMhAmqx
7SNr6q3kNSpOQgTUYNk3ZtVbyG3dvYMIWJuPfObVW8lt5U0iRMCavHdGO+ot5Df3QkIErEWL
6q0INPvEQQSsQcPqLUg0P5QIEbA4rau3IPM+9hIiYGn6sO+D0J+S6yAClqWT7Lcilc7XRIiA
RXnZuBGzKGJ/U38SImBJevRvEu3V/oeABenUvzdiCiJgMXrr/u0QensIWIqO098XkUqMgIXo
3783+QoiYBnG8G/KT4MIWIRh/HuTpSACFuA1lH9TVhpEQHle02D+vUlVEAHFGdK/KVVBBJRm
VP+mtEqMgLK8BvbvzWMFEVCUf/oN7d/0OA0ioCSDp7+FJwoioCD4txCfBhFQjNG7fzsiFURA
Kf593vjnEaUgAgqBfwEiKjECyoB/J9wpeO/OHFpo/iM+SO/g3znXafDWnbdm82Ep/5nRBXzh
3zUXCt4LGFzKS4CjC/j+dPHvmlMFkwV0s6Cv42jgXxSBShzlzXy6FH3AP97lF/+iCKXBiIOQ
M0sRcKL795BjGkx0Z1eCM5rUNpTfx+wUjMmAoYU4CHmDfyl4aTCmDxgYhtktk9ukRsG/VDYF
I46CgyPRu2VG5IV/GSwKImAqfx8g/qXzqcQZwzDOMkJNagn8E+CfghnDMM4iMs1pCfyT4cVs
mCTwT4rE2TBPg/TFC//EiJkNQx/Q56Mf/okQMxkhOBL9KEhXkP4kYRjmKfgnCmdCnkH3TxgO
Qh7xGb7HPzkYhnkC/olz7U7kPOdRBMQ/ee4EjFJwDAFf+FeA2+5djIFDCPidvYF/skSdC84P
0j74V4aY/MaZEPwrRpQ7wwu4dP/wTxyGYSIg/ZWDgeh78K8gzIa5Bf9KwmyYO/CvKMyGueaF
f2VhNswly+Wr+FcKDkKuwL/iMAxzAf6V534ywrDXBb/wrwIIeMZ69xL8K0niHVIfBmmQNf3h
X1EQMAzltxLcGyYE3b9qcG+YAHT/6sEwzBH8q0jUQLTAIg2BfzWJmQ2TH6Ql8K8qItd7dCTg
C//qgoAe2+3b8a8ODMO44F91ENAB/+rDMMyK0/3Dv2owEL1A+lOBEvwF/3RgMsIH/FMCAd+8
8E8LSvDkpj/8qw0HIfinCsMw+KfK8JdlvvBPlajZMOEavD3bsIDu98fjnwLpR8FzDwLinzbJ
As49COiWX/xTIXUYxrtjTMRIjUno/ukS582Zf833ATn8sECiO35ebFJAun8miMmAJwu1LSD+
2SDj/oBNC4h/RhjzDqkv/LPCkAK6+uGfLiPOhsE/Qww4Gwb/LDHcbJgX/plitHvD+PrhnzqD
3RuG9GeNsW7NgX/mGEpA/LPHQMMwHH5YZBwBPf3wzwrDDMPgn01GERD/jDKGgC/8s8oQAvr6
4Z8lRhAQ/wwzgIC78ot/puheQLp/tuldQMqvceLmAzY7EI1/1un7TAj+mafryQj4Z5+OBXzh
XwP0W4J3+uGfTboVEP/aoNdhGPxrhD4vy9x3//DPLF2W4IN++GeWHr+ohvTXEB0KiH8t0WEJ
ZvivJfo7CMG/puhuGAb/2iLOnXZKMP41Rt8C4p95rt35uz90Swch+NcafQmIf83R1Tgg/rVH
V31A7973+NcEPQ3D8N0LDdJRBsS/FulHQPxrkruj4LmZo2C++7JJuhEQ/9rkRsCopSwIiH+N
0kkfEP9apZNhmE1A/GuLPjIg/jVLFwJSgNulh6Ngy/79vNFuhGVSBfSeNCOgJf9+NvdQ8JzE
YZi3fZuBugJa8+/n55j2SINnZPQBjQhoyL+Aed6LVRvTCKnu+CU44sq5UpjwL5T0govVaEw7
xHtjOAOuAur4F2eeu3jBxrRI6wKq+ReV9H4/7Fcs2KzmSLwmxMpBiEYBvjPvd2N7ZhehXOta
I/WiJBvDMHX9u0p6R+sOr+9CybevSdq+KKlWAT4x786649J+TLH2NUzTp+LK+xdIes+s27F3
MLN5HdDybJii/vnmZVnn44UgDcbdHctkBizk35b0BK3zwcGNhu8PuAgo5t+feMWs89k5WHJT
tokRMD9ICQT9q2Wdj7u1cdNgTAkWCCJPfgFWse7YhuXhoA62WoJT/XOsMzJTz3NQsyE6tC5g
lH9ernt49rYGm4PWWlaeRodhIvw7VNjIKSs6uA6qNqQ2bQp47d+hX2fZvA33L0W3JTVpUsAb
/7aHppNegPUPp6VG59GygFf+NWaew+agckPq0KKAd/61qt7K18HW30YUDQp4WYDf/lVsSzGG
cbA9AYfw783qoHZDitKsgN379+bjYNdpMHIgOu7y4RqM5N+bdfRcuyGFiBXwcrmKAo7m3x9f
B7WbUYQod+ab5eoJOKR/b94OdpkGmxRwPP/e9OlgXAm2IuDI/r35OKjdClGiBMwOIsRFAR7C
vzefiWTarZCjpWEY/PvSk4MRGfB+qaoChv3rZodE8nZQuw0ixF0TYkLAS/+qtMAWfTgY0b8z
IiD+HenAwZgDjNmCgPgXRvOSKgmiBLRwTcifgPgXQvW6vlyihlgMCIh/l/w062AjwzCnBRj/
vvw06mAbwzD4F0OTDrYxDHNWgPFvR0MOfi+ZbWIYBv/i+bHr4K/H98kWhmHw7xnfe3xpN2M6
Uc6ngWEY/HvO+8ykhoO/Ecr5NDAM8xYQ/57yU8nBx8btsD8Mg3+pFHIwVzkf8zcpPynA+BfF
cqvhvCiyyn3atWBdQPzLZLvd9YOVnnflrltwYHs19Ytq/MXyWnhFuADj3xO+O/zSJBnjQq7d
7CnjAuKfDF8NXLdylXvuWpC46z20BMQ/MX42B58rJyRbCNN9QPwTJcqahCqahelhmBf+CeO7
VNm1IDFf03B7XWYhAfGvAJqyhTB8l/xgAca/zrB7EHLSAcS/vjAtYKgAQ1/cjQOe3Zyt+Dem
498YJAr4N016fbaAgPg3CInulBYQ/0YhZhjmZCFHwJhbaD3ihX8DEOXN/Hc+OPz8+li0WRP+
DUTqRUmek9IChgow/vVJooB+ThQWEP8GIvFMiP+suID4NwwGzwXj30jYmw2Df0NhTkD8Gwt7
AuLfUFgTEP8Gw5iAxwKMf31jS0D8Gw5jAuLfaJgSEP/Gw5KA+DcgpgTc/Y5/A2BIwH0CxL8R
sCMg/g2JGQF3/v3g3xjYEdD7Df9GwYqAfgLEv2EwIiD+jYoVAd1f8G8gbAjoJUD8GwkTAuLf
uNgQ0HmMf2NhQUD8GxgDAroFGP9GQ19A/BsaAwJuD/FvPNQFxL+x0RbQKcD4NyLqAq6PTHzF
N9RGWUDHP4mGQHPoCrgVYPwbFFUB8Q90BVwe4N+waAq4+Mfhx8AoCrgUYL59a2Q0Bfz8wL+h
0RMQ/2BSFPBbgPFvcPQEfP/3i3+joyXgxz++fXp4lATEP/igI+BfBxD/QE3A6X34gX+gI+CL
ww/4oiHgvwJM+YUPKgLiHywoCIh/sFFfQPwDh+oCvn7xDzbqCzjhH2zUFhD/wCNZQPdr1OOD
4B/4pAo4Jwn4+8I/8EgUcE7JgL/4B3tkSvDsJcQTfif8A5c4b05Xdh7HrPD7rweIf7CjmoD4
ByEqHgXjHxxJPQjxyndUEPyDAPUGovffBgwwVRQQ/yCE9g0qYXAQEFRBQFAFAUEVBARVEBBU
QUBQBQFBFQQEVRAQVEFAUAUBQRUEBFUQEFRBQFAFAUEVBARVEBBUQUBQBQFBFQQEVRAQVEFA
UAUBQRUEBFUQEFRBQFAFAUEVBARVEBBUQUBQBQFBFQQEVRAQVEFAUAUBQRUEBFUQEFRBQFAF
AUEVBARVEBBUQUBQBQFBFQQEVRAQVDEloFAcmlMhjHZz3C9M7+U9FYpDcwqEedu3GdjHeyoV
h+YUCIOA1cPQHG+1eXJq8AyQSqqA85S6LkA2fgkGqAwCgi7p1RsAAAAAAACgbaSOieWOrUXi
CDVHJswnRnYsoTDbB5wXSKY5UqOCcqOLYrtcII5MmM87yo4lFGb7gPM+abF3ZUxAyZwjEiY7
1PfMZ24soTDTeiI275N2mpOFPzUhO5ZEDJkw5kpw/ictVDrX2ilRgrM/aLmpCZZKp60SvO4q
kU5X/gctVsolwgiWToEgU840Hz+OQQGlev1CzZE4fLAjoODpZQS8CyPRHO9BXnOya7BUZ0mw
5y8QxEyY5aPJjPUNk/1BOwGyDkJk3hUAAAAAAAAAAAAAAACMB2eYoDCX59HFZqkBnHA5QQ/7
oDSLgP58jnkOzHraJn7MW+ZkHghksc5vcnX7/raXcq3Jhx8AiXwv0ggK6KvlTJ9zVsA+yCJX
QBSELIKl9FTAZTLyyXoATwkfTFwehGy/cRAC1cE3UAUBAazzP6BbPGL+6huzAAAAAElFTkSu
QmCC
--------------050209080604000903020002--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
