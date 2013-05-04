Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id C74AE6B0289
	for <linux-mm@kvack.org>; Sat,  4 May 2013 17:36:35 -0400 (EDT)
Message-ID: <51857F60.8000209@bitsync.net>
Date: Sat, 04 May 2013 23:36:32 +0200
From: Zlatko Calusic <zcalusic@bitsync.net>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] mm: lru milestones, timestamps and ages
References: <20130430110214.22179.26139.stgit@zurg> <5183C49D.1010000@bitsync.net> <5184F6C9.4060506@openvz.org> <5185069A.1080306@openvz.org>
In-Reply-To: <5185069A.1080306@openvz.org>
Content-Type: multipart/mixed;
 boundary="------------090204050809060404080601"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org

This is a multi-part message in MIME format.
--------------090204050809060404080601
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 04.05.2013 15:01, Konstantin Khlebnikov wrote:
> Konstantin Khlebnikov wrote:
>> Zlatko Calusic wrote:
>>> On 30.04.2013 13:02, Konstantin Khlebnikov wrote:
>>>> This patch adds engine for estimating rotation time for pages in lru
>>>> lists.
>>>>
>>>> This adds bunch of 'milestones' into each struct lruvec and inserts
>>>> them into
>>>> lru lists periodically. Milestone flows in lru together with pages
>>>> and brings
>>>> timestamp to the end of lru. Because milestones are embedded into
>>>> lruvec they
>>>> can be easily distinguished from pages by comparing pointers.
>>>> Only few functions should care about that.
>>>>
>>>> This machinery provides discrete-time estimation for age of pages
>>>> from the end
>>>> of each lru and average age of each kind of evictable lrus in each
>>>> zone.
>>>
>>> Great stuff!
>>
>> Thanks!
>>
>>>
>>> Believe it or not, I had an idea of writing something similar to
>>> this, but of course having an idea and actually
>>> implementing it are two very different things. Thank you for your work!
>>>
>>> I will use this to prove (or not) that file pages in the normal zone
>>> on a 4GB RAM machine are reused waaaay too soon.
>>> Actually, I already have the patch applied and running on the
>>> desktop, but it should be much more useful on server
>>> workloads. Desktops have erratic load and can go for a long time with
>>> very little I/O activity. But, here are the
>>> current numbers anyway:
>>>
>>> Node 0, zone DMA32
>>> pages free 5371
>>> nr_inactive_anon 4257
>>> nr_active_anon 139719
>>> nr_inactive_file 617537
>>> nr_active_file 51671
>>> inactive_ratio: 5
>>> avg_age_inactive_anon: 2514752
>>> avg_age_active_anon: 2514752
>>> avg_age_inactive_file: 876416
>>> avg_age_active_file: 2514752
>>> Node 0, zone Normal
>>> pages free 424
>>> nr_inactive_anon 253
>>> nr_active_anon 54480
>>> nr_inactive_file 63274
>>> nr_active_file 44116
>>> inactive_ratio: 1
>>> avg_age_inactive_anon: 2531712
>>> avg_age_active_anon: 2531712
>>> avg_age_inactive_file: 901120
>>> avg_age_active_file: 2531712
>>>
>>>> In our kernel we use similar engine as source of statistics for
>>>> scheduler in
>>>> memory reclaimer. This is O(1) scheduler which shifts vmscan
>>>> priorities for lru
>>>> vectors depending on their sizes, limits and ages. It tries to
>>>> balance memory
>>>> pressure among containers. I'll try to rework it for the mainline
>>>> kernel soon.
>>>>
>>>> Seems like these ages also can be used for optimal memory pressure
>>>> distribution
>>>> between file and anon pages, and probably for balancing pressure
>>>> among zones.
>>>
>>> This all sounds very promising. Especially because I currently
>>> observe quite some imbalance among zones.
>>
>> As I see, most likely reason of such imbalances is 'break' condition
>> inside of shrink_lruvec().
>> So can try to disable it see what will happen.
>>
>> But these numbers from your desktop actually doesn't proves this
>> problem. Seems like difference
>> between zones is within the precision of this method. I don't know how
>> to describe this precisely.
>> Probably irregularity between milestones also should be taken into the
>> account to describe current
>> situation and quality of measurement.
>>
>> Here current numbers from my 8Gb node. Main workload is a torrent client.
>>
>> Node 0, zone DMA32
>> nr_inactive_anon 1
>> nr_active_anon 1494
>> nr_inactive_file 404028
>> nr_active_file 365525
>> nr_dirtied 855068
>> nr_written 854991
>> avg_age_inactive_anon: 64942528
>> avg_age_active_anon: 64942528
>> avg_age_inactive_file: 1281317
>> avg_age_active_file: 15813376
>> Node 0, zone Normal
>> nr_inactive_anon 376
>> nr_active_anon 13793
>> nr_inactive_file 542605
>> nr_active_file 542247
>> nr_dirtied 2746747
>> nr_written 2746266
>> avg_age_inactive_anon: 65064192
>> avg_age_active_anon: 65064192
>> avg_age_inactive_file: 1260611
>> avg_age_active_file: 8765240
>>
>> So, here noticeable imbalance in ages of active file lru and
>> nr_dirtied/nr_written.
>> I have no idea why, but torrent client uses syscall fadvise() which
>> messes whole picture.
>
> Hey! I can reproduce this:
>
> Node 0, zone    DMA32
>      nr_inactive_anon 1
>      nr_active_anon 2368
>      nr_inactive_file 373642
>      nr_active_file 375462
>      nr_dirtied   2887369
>      nr_written   2887291
>    inactive_ratio:    5
>    avg_age_inactive_anon: 64942528
>    avg_age_active_anon:   64942528
>    avg_age_inactive_file: 389824
>    avg_age_active_file:   1330368
> Node 0, zone   Normal
>      nr_inactive_anon 376
>      nr_active_anon 17768
>      nr_inactive_file 534695
>      nr_active_file 533685
>      nr_dirtied   12071397
>      nr_written   11940007
>    inactive_ratio:    6
>    avg_age_inactive_anon: 65064192
>    avg_age_active_anon:   65064192
>    avg_age_inactive_file: 28074
>    avg_age_active_file:   1304800
>
> I'm just copying huge files from one disk to another by rsync.
>
> In /proc/vmstat pgsteal_kswapd_normal and pgscan_kswapd_normal are
> rising rapidly,
> other pgscan_* pgsteal_* are standing still. So, bug is somewhere in the
> kswapd.
>

Not necessarily, because processes also do a direct reclaim. Also, if 
you continued the copying, I bet you would see that DMA32 zone also gets 
to play. Just a bit later.

I can now see that effect nicely on the graphs I prepared. Attached is 
one from the desktop. Where the red line suddenly drops, I copied 2GB 
file from the network to the machine. Half an hour later I copied 
another 1.6GB file. That's when the blue line dropped. Though, it all 
makes sense, about 3GB of I/O was needed to expunge all old inactive 
pages from both zones, the first 2GB wasn't enough to push old pages 
from the DMA32 zone.

I'm of the opinion that your instrumentation will be of use only when 
there's a constant reclaim goin' on. Otherwise pages stay in memory for 
a long long time, and then it doesn't matter much if it's one hour or 
two hours before some of them are reclaimed. For the same reason I will 
limit graphs like these to some useful value, so to get precision for 
the important time periods when the reclaim is really active.
-- 
Zlatko

--------------090204050809060404080601
Content-Type: image/png;
 name="memage-hourly.png"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="memage-hourly.png"

iVBORw0KGgoAAAANSUhEUgAAAkEAAADBCAIAAABHSfMLAAAABmJLR0QA/wD/AP+gvaeTAAAg
AElEQVR4nO2de1gTV/7/TzCtiuICqaAtVWtQlADqcvGJQiRqi9ZWy9pVn268rLJuXcV+C1q3
3m1tVbBotZb2V8TL1q9beNrSra12RURiUL+CF24t1tgWFIkhhIsiQiC/P45Ox8nkfpkLn9fD
kyecfObMec8kc857zplzBJcvX0YAAAAAwDV0Op2Q6TIAAAAAgN1otdqbN28+rMMGDBjAbGkA
AAAAwHbwTUQvposBAAAAAA4CdRgAAADAVaAOAwAAALgKjOkAAAAAWEpBQQElZfLkyeR/wYcB
AEBFLBa7O3+MW/cC8IDJkydPnjw5NjYWmdReGPBhAAB4GrVajdxfUwL8oL29/aeffhIKhc3N
zUIhtc4CHwZYJycnRywW5+TkMF0QuzF3lSR8QFhY2JQpU7Zt29bU1EQbD9dZAGCQmpqaixcv
9u/fPyws7OrVq0FBQZQAqMMA6+Tn58fHx586dYrpgrgStVqtVqtLS0s//fTTxsbGFStWMF0i
AACoNDU1RUVFBQcH+/v7y2Sy4cOHUwKgDgOscP/+/QsXLmzevPn8+fP379/HiQkJCZcuXcLv
L126lJCQgN93dXXt27cvPj5+3Lhxq1atamtrI/IRi8WfffZZbGxsWFjY/v37ifT//Oc/U6ZM
GT169F/+8pebN2/ixM7OznfffTcmJiY6OvrgwYOEGbKQv2P07t07ODh43bp1jk26JhaLs7Oz
o6KiYmJitmzZ0tHR4TFd7s7/xIkTU6dODQ0NnTVrVlVVFU5sa2tbv359TExMTEzMhg0biO8D
xa2S/zV33mmZOXOmUqnE7x88eBAZGanT6awWFeAxDQ0N586dKyBBCYA6DLCCSqWKiIh49tln
w8PDVSoVTpw+ffrx48fx+++///7FF1/E7w8cOHD+/PnPP/+8sLBQKBRmZGRQsvr888+LioqK
ioqIxB9++CErK+vSpUuxsbEbNmzAiZmZmb/++uu33357/Pjx8+fPE8GW83eAzs7O2tra3bt3
S6VSx3K4cOHC999//91339XV1WVmZhLp7tbl7vyPHTt26NChkpKSqVOnbtq0CSd++OGHWq32
u+++O3bs2O3bt/fs2WPDEaI/77TMmzfviy++wO8LCgrGjh0rEols2QXAV6yO6RDg5ifMNQWY
Y82aNRKJZMGCBYcOHfrxxx+3b9+OEKqurk5KSlIqlUajMS4uLjs7e+TIkQih559/fv/+/UOG
DEEI6XS6V155hWhWi8XiwsLCZ5991tyO2traYmJiKioqEEJyuTw7O/u5555DCP36669TpkzB
owAs5E+LWCzGG5qm9+rVq0+fPgihe/fuzZw58/333+/bt69pvLkciE9PnTo1bNgwXM7Fixeb
thPdocvd+YvFYpVKNWjQIITQ/fv3o6Ojcf6TJk06dOgQ1nvjxo3FixcXFhaaHiXyvxbOu+mx
vXfvXlxc3MmTJ0Ui0euvvz5jxoyXX37ZxuMA8BU8pqOlpWXMmDFXr16VyWQ4/cyZMwjGJQKW
6e7uPn369MqVKxFCU6ZM2bdvX3d3t5eXV0hISJ8+fa5cuWI0Gr29vXEFhhCqq6uTy+XE5l5e
jxl90/7YysrKHTt2VFRUNDc3k9M1Gs0zzzyD3z/99NNEuuX87eLatWv4zc8//7x06dILFy7E
x8ebZmh1F0Txnn76aY1Gg9+7W5cHjhuuwBBCffv2Je4Z3rlzh8j2mWeeuXPnjtV8EN15N0e/
fv0SEhK++uqrOXPmXLx4cdeuXTZuCPCVmpqa3377bfDgwUOGDKEd0wF1GGCJy5cv63Q6ouGD
UyIjIxFC06dPP3HihNFonDZtGvFpUFBQTk7OH/7wB9rcBAIBJWXFihXLli376KOPBgwY0Nzc
/Mc//hGnBwYG1tbW4m6VW7du2Zi/Y4wYMWL79u3r1q2TyWT9+/c3GAzE+N2Ojo7+/ftb3ryu
rg77krq6uoEDB3pGF1PHbeDAgbR6+/Tpc//+/b59+yKEbt++TdnK9LwTWz148KB3797kxHnz
5qWmpvr4+Mjlcpwh0JPBYzrwN4F8ISKA/jDAEidPnkxOTlY/Ijk5OT8/H3+Eu8SOHz9OdIYh
hObNm/fPf/6zpqamo6Pj8uXLS5cutZx/e3u7SCTq27fvzZs3iU4XhFBiYuLWrVvr6+t1Ol16
errD+dvI+PHj/fz8Tp48KZVK09PTb926ZTAY7ty5s3PnTqv9ZNu3b9dqtQ0NDdu3b585c6Zn
dDF13KZNm4b1arXa7du3E82X0aNHZ2dnt7W11dXVvffeezbmNnr06C+//LKrq4ucOGbMmD59
+uzatWv69OmOFRLgEzCmA3CK/Pz8qVOnEv9OnTqVqMNGjx4tFAqfeOKJUaNGEQELFy6MiYlJ
SkoaO3bspk2bZs+ebTn/tLS09PT08PBwhULx/PPPE+nLli0bPnz4yy+/PG3aNKlU2qtXL8fy
R6RHwSzPDZGUlPTZZ5/t2LGju7t73rx54eHhs2fPNhqNO3bssJx/ZGTktGnTpk+fPmjQoOXL
l3tGlweOGy3/8z//4+/v/+KLL7744osikeiNN97A6e+8885///vfyMjIBQsW2N6DtWnTpkOH
DoWEhFBOyty5c+/evTtx4kTHCgnwCS8vr/j4eDyyg/ZuP4zpANiORqOZM2cO7r9lG5ZHfFjG
3brYfNws8+233x47duzTTz9luiAA85SWlgYEBOBe2Lq6Oq1WS9w5x99t8GEAS0lJSblx40ZL
S8uHH35Ithpcx926uH7cOjo6jh49SjxxCPRwRo0a1dDQoFKpVCpVQ0MD+a4PBsZ0ACwlLi5O
oVB0dHRMnjz5zTffZLo4LsPdurh+3EaPHj1+/HgYUg9g+vXrN27cOOLfgoICylNicC8RAAAA
4AbkOgyeDwMAAABYjelARApQhwEAAAAshXLnEMbWAwAAAPwB6jAAAACAG5hO+8uTe4l1//d/
CKGnY2KYLggAAADgMvR6vVqtxqsFeXt7BwcH+/r6kgP4UIcZ2tvPf/CBoFevmQcP9nrySaaL
AwAAALiGqqqqkJAQf39/hJBOp6usrKRM4MKHe4mV//73vTt37t6+XXn0KNNlAQAAADwH531Y
S21txf/+L35fcfTo8Bde6D94MLNFAgAAAFxCaGjo9evXKysrEULe3t6hoaGUAM7XYaWZmd2d
nfh914MHFz/6SG7ztNkAAAAAm/Hz84uOjrYQ4Ol7iabTh2s0GoVCERERMX/+fK1Wa26r/fv3
I4SysrIoU1zL339//unTd156af7p0/NPnzatwHQ6ndVSeTJGYG05dg+XB3RZBnRxKwZ0cSvG
Knq9vqSkpKioqKioqKSkpKmpiRLAQH8YsRgV/jctLS00NFSlUo0aNSotLc3cVjk5OUajMScn
x97ddT5yaSyJMXp7s6o8oMsyoItbMaCLWzFWqaqqGjZsWGxsbGxs7NChQ/FNRTIM3EuMjIzs
7u4eP3785s2bBw0aVFxcnJeX5+Pjk5SUlJiYaG4rX1/fjz/+2N/f39xSF8OHD6dN7+zsNPcR
IzHNlZV/YFN5QJflGNDFrRie6ZLJWpVKA0Jo4XPo0C9+pHThmTM+7CwzbcyNGzcsBzuMp32Y
Wq0uLS09derUkCFDVq1ahRDS6/UikSgpKUkkEjU2NprbUKFQ7N69W6FQUD9oakK5uail5W5h
IULI9PWZ27dp05mK6eXjw6rygC7QxYbygC7aT5VKwytBxQih5s5+CCH8/pWg4qIiA2vLbBpj
aGhAubkCh1baCw0N/eWXX5RKpVKp/PXXX03HdDA2b/3du3elUml5eblUKs3LywsMDNRoNImJ
icXFxabB5JUGaVcd/OCDD/bt20e7oxs3blhtL3gy5m5hYf/4ePaUB3RZjgFd3IrhmS6BQI8Q
Mhr9yLqIRHaWmTbGHT4Mz1vPTB1279697Ozs4uLio0ePpqSkBAQErFixYu/evTqdbufOnabx
ztRhAAAAHIW2ujJXh7EZh+sw00l+KWuvMDMuUSqVXr58GY/gWLNmDXZjFRUVq1evdvkebTl2
nozBLps95QFdlgFd3IoBXdyKsYXJj0P5lCdrYIIPAwCAf4APM124mYAZH+Z52Nbu4Gt7CnRx
KwZ0cSuGr7qcB3wYAAAASwEfZgHwYczE8LU9Bbq4FQO6uBXDV13OAz4MAADA7bTKZAnKf55D
Uge2BR9GC/gwZmL42p4CXdyKAV0ejjEoleYqMImk1tzmQmSIQ0rEYl1OxjgP+DAAAAC3oxcI
/FEjstM/6QUChJCf0UhOBB+GAR/GTAxf21Ogi1sxoItbMXzVZZmSkhKNRmN8vAqnwPk6rLOz
s76+vrm5GT06ZJTX4cOH06YzFdM/Pp5V5QFdoIsN5eG9rlqJBD26bWh7PngrU1325sNsTHV1
dX19vQNLsYwcOVKn0507d+6XX37p6OigjeH/vcQbLJtDjGfzuRGALm7FgC4Px1i4l2ghH+Je
Yk+eL7Gjo+PWrVu3b9/29fUNCgoiaism50t0OdAfBgAAm4H+MCdz6O7u1mq1tbW1UVFROAX6
w5iJ4et9bdDFrRjQxa0YvuqyHS8vr8DAQKICIwAfBgAA4HbAh7k8T/BhzMTwtT0FurgVA7qc
jJnoqwoLKxMI9Jb/iBhcgTlcHr6eL+cBHwYAAGAfrTLZAOU39m4lFHTFxfcuKPCxfRPwYRYA
H8ZMDF/bU6CLWzGgy5kYg1KJEJJIao1GP8t/arWeeN/Z/RRtBcYeXZ6PcR7wYQAAAPbhWOeW
YztC4MPMwKQPy8zMFIvF+L1Go1EoFBEREfPnz9dqtbTxYrF4//79CKGsrCxiQxthW7uDr+0p
0MWtGNDlfIyFeQ5dvi++ni97KSgooKQw4MOqqqoWLVqk0+nUajVCKDU1VSQSJScn79mzp6mp
KT093XQTsVgcHBx84sSJhIQEtVqNNyQDPgwAAI8BPsxeXFWfkZd1ZsaHdXR0pKamrlu3jkgp
Li5esmSJj49PUlKSSqUyt6Gvr+/HH3/s7+9v7x7Z1u7ga3sKdHErBnQ5HwM+zPkYqxQ8jmmA
p+uwDz74YMSIEbNmzSJS9Hq9SCRKSkoSiUSNjWaHnyoUit27dysUCuoHTU0oNxe1tOBzbPoa
UFNDm85UDIY95QFdoIsN5eGWro6gIITQiOZaj+2LrOuVoGLGj7NdMYaGBpSbKzC5f2YLkx/H
NMDT9xJHjBjR3d1N/KtWq6VSaV5eXmBgoEajSUxMLC4uNt1KLBYT9w/J7wlgvkTGY0AXt2JA
FyVRJmtVKg3EvxJJbWXls5bzkUhqKyoiHNiX7TEwXyIF03uJjI1LJKqilJSUgICAFStW7N27
V6fT7dy500Iwsr8OAwAAsAquGGxHiAxx8j52PezlANAfZgG2PB+2Zs2a8vJyqVRaUVGxevVq
l+fPtvu/5DsebCgP6LIM6OJWjJO6GpE//rsqiSPe0/wJAxrlc7Oy6MdR21vmnny+rKLX60tK
SoqKioqKikpKSpqamigB8HwYAAAAS80N+DCVShUSEoJH8+l0umvXrk2cOBF/xBYf5m7Y1u7g
a3sKdHErBnRxK4avupwHfBgAAABLzQ34ML1ef/369ba2NoSQt7d3cHCwn99D4eDDmInha3sK
dHErBnRxK4avuqzi5+cXHR09adKkSZMmRUdHExUYAfgwAAAAlpob8GGmzzUzPE+H52Fbu4Ov
7SnQxa2YnqCrVSabIPjewppe5D8Gy9yTz5ct4EqLLc84uwnwYQAAUCBmNbQFITJM8PvpTGOc
W4tkL+DDioqKxo0bV1JSEhUV5eXldfny5djYWPwR+DBmYvjangJd3IrpUbosrOn1++JexoHk
CowTuhgsj8d82ODBgy9fvjxy5Mjy8vLS0lLTdUs4X4d1dnbW19c3NzejR4eM8jp8+HDadKZi
+sfHs6o8oAt0saE8btKFp+VleZktxNRKJDzQVV1dXV9fr9PpkP2MGDFCJpM988wzEyZMkMlk
gwcPpgTw/17iDZbNIQbz1HErBnRxK4asy9wKKWwrs4UYmC+RPEEiYtV8ia4F+sMAAKDgsVW+
3Af0h8G4RJuOnSdj+HpfG3RxKwZ0cSuGr7psgV1rr7gJ8GEA0KOY6Ksqbg61MZhbloUM+DAL
gA9jJoav7SnQxa0YTutqlcnMVWB4fUgCoaBLLhe6uzweiOH0+XIr4MMAAOAYPOjoshHwYRYA
H8ZMDF/bU6CLWzGgi1sxfNXlPODDAADgGODDENe088eH/fDDD9OmTQsLC3v11Vdx9anRaBQK
RURExPz587Va+nVRxWLx/v37EUJZWVmmz2lbhm3tDr62p0AXt2JAF7di+KrLeTztw1auXLly
5cohQ4YUFha+8847Z8+eTU1NFYlEycnJe/bsaWpqSk9PN91KLBYHBwefOHEiISFBrVar1WpK
APgwAOg5gA9DXNPOHx+2Z8+e4ODg7u7uBw8eeHt7I4SKi4uXLFni4+OTlJSkUqnMbejr6/vx
xx/jFantgm3tDr62p0AXt2JYq8vcZPPk+eYtzOTLWl1OxvBVl1X0en1JSUlRUVFRUVFJSUlT
UxMlgIExHWKxWCKRbN68edeuXbiIIpEoKSlJJBI1Npr9aioUit27dysUCuoHTU0oNxe1tOBz
bPoaUFNDm85UDIY95QFdoIsN5SFiDEplYJARPRolT34d0VxLvJ/97Fm5XMghXQ7HdAQFUXTh
I8DmMlPPaUMDys0VmNw/s4Wqqqphw4bFxsbGxsYOHTq0srKSEsDMmI779+//8MMPn3766fHj
x6VSaV5eXmBgoEajSUxMLC4uNo0Xi8XE/UPyewKYL5HxGNDFrRjW6rJwn5DTuhyLgfkSVSpV
SEgIvgOn0+muXbs2ceJE/BEz8yWuWbPmjTfeeOqpp/Lz87ds2XLhwoWUlJSAgIAVK1bs3btX
p9Pt3LnTdCtn6jAAADhEz+nrsgXoD9Pr9devX29ra0MIeXt7BwcH+/k9FM5Mf5hMJnvttdfG
jh2bmZmJ7yWuWbOmvLxcKpVWVFSsXr3a5Xtk2/1f8h0PNpQHdFkGdHErBnRxK8Yqfn5+0dHR
kyZNmjRpUnR0NFGBEcDzYQAAsAjwYWTAhzk+bz1+DOv+/fuvvvpqdHQ0juYibGt38LU9Bbq4
FcOUrom+KofHHLJZl7tj+KrLFnClZfe89bjb6dtvvz169OjKlSu3bt167NgxlxTIHYAPAwBO
gD2EZYSCrrj43gUFPh4oD8sBH4YXvSSWvjRdA9OsD3vyySe7urquXr0aGxsbHR1tOoyCK7Ct
3cHX9hTo4lYMs7qMRj/Kn1qtJ953dj9FW4GxX5f7Yviqy3nM+rDp06e///7769ate/vtt+Pi
4mhHA7IH8GEAwAm46CEYBHwYBTt8WEpKCn7ueMKECS7ZN1Owrd3B1/YU6OJWDOjiVgxfdTkP
jEsEAMCV2LLCMrc8BIOAD3N8XCJX6OzsrK+vb25uRo8OE+UVY+5Tz8fcLSxkVXlAF+hy7b6K
m0MlklqEEPGK//B7ITLMGX+Wi7oYiamVSGh14ePJzjKbxlRXV9fX1+t0OmQ/kx/HNMCsD1u7
du2JEydaWlqMj5oA0B8GAIBVuOgSWAv4MAp29IeVlpZmZ2dXV1erH+GSEngeW46dJ2P4el8b
dHErBnRxK4avuuzF1IqZ9WFvv/12Tk4OOYXN1Rj4MABgCVx0CawFfBjZeCG7fNjPP//85Zdf
Xrt2DXyYa2P42p4CXdyKcUYXeYkvYn4N4s+x8rBBF5tj+KrLFgpImH5qaZ4OSgqbqzHwYQDg
MYgpDWkRIsMEv5/ONMZ5skh8BXyY4z5MbYJjJWActrU7+NqeAl3cinGJLsr8Gg9n2TAOpFRg
nNPFwhi+6rIKpQPMjv4wbgE+DAA8Bkwt7zHAh1mAJ8+HWYVt7Q6+tqdAF7diQBe3YviqyyoF
JlACPO3D8vLy9uzZo9FoQkJC1q5dGxUVpdFoUlNTy8rKxowZk5GRMXDgQNOtxGLx2rVrlyxZ
kpWVtW3bNljHGQA8gNUZN7hlBbgI+DDM9evXm5qaxowZ88QTTxCJzPiw/Pz8zMzMS5cuLViw
IDk5GSGUlpYWGhqqUqlGjRqVlpZmbsOcnByj0UgZ7m8LbGt38LU9Bbq4FWOLruYgs6ufCAVd
crnQheWB82UZvuqySnt7+5UrV/R6/dChQysrKx88eEAJYKw/7ObNm1OmTKmsrIyLi8vLywsM
DNRoNImJicXFxabBYrE4KipKJpMplcqLFy+CDwMAD8DF9j7PAB+mVCqHDBkyZMgQgUDQ3t7+
008/jR07Fn/EZH+YXq9PTk5euHChUCjU6/UikQjPkd/YaHbArkKh2L17t0KhoH7Q1IRyc1FL
C26nmL7eyMmhTWcqpiEzk1XlAV2gy9zr8vHHWFXmnnm+OoKCKLpeCSpmeZkpMYaGBpSbK3Bo
cHtkZOTQoUMFAgFCqE+fPhKJhBLAgA+rrKxcvnz5jBkzUlNTvby8pFKpLT6M8F60K5mBDwMA
h7Hc78Wt9j7PAB/Gunnrc3Nz169fn5GRsXr1ai8vL4SQVCo9cODA3bt3s7Oz3bFWGdvu/+IW
CnvKA7os0xN0mavAIiS/yvwqPFMeOF+W4asuW8CVlt3z1rsJyvQf5eXlra2tKSkpZWVlERER
GRkZgYGBtFuBDwMAN8HFdn0PAXwYnpiDmJ7Djnk63ARl7g9vb+/AwMAjR46Ul5cfOXKEtgJD
j09zZe+MIWxrd/C1PQW6uBUDurgVw1ddzgPzdAA9lFaZzKBUCmUynzNnmC6Lh2iVyRKU/zyH
pLSfcqtd30MAH2YBmKeDmRi+tqc4p8ugVNZKJIaiIsthnNNlIcagVBIVGB7bhhEiA22/FxvK
bG8Mn84XGb7qsgrr5ulwE+DDAFuQyVqVSgM5ZQIqVhlnMFUeDwPzHHIOCz5MJhOeOWP2IXS2
4WR91tHRcfbsWXLHGAIfxlQMX9tTLNfVKpPpBQJKBSaR1BYjK0NhWa7LQoxM1kpZ2Yu8YAp3
dVmmJ+iKixMihIqKDJQYtpXZVfcP29vbq6qqhEJhc3OzUCikfAo+DOgR4PYsvog3In+EEBIK
/Q13EH9NCe1ylEJkiJP3KSjgTPu9h0PrwxAHu8Qcrs9qamp+++23wYMH+/v7V1RUBAUFDR8+
HH8EPoyZmJ7QTmRDeW7cuEE2Iv6okXAhj9a56pRIaq3mw0JddsU0Iv/f/4QBjfK5uALjui5z
gC5uxVilqakpKioqODjY399fJpMRFRgB+DCAt5gaEaEQxcUJCRfCucasXfBbXQ8BfJgFeOLD
Ojs76+vrm5ub0aPDRHnFmPvU8zF3CwtZVR5e6qqcO7csLAzbrKuSuEbkj1+rq/UFBT5EpERS
i2O4ostCzERfVVhYmUCgDwsrw38IIQvquKKL099D52NqJRJaXbRnliVlNo2prq6ur6/X6XTI
DYAPA3iC6ZhDDNH7JYyL83l8YC7nGrMWoDGdyDDB76czjXGMlAdwCeDDLMATH2YVW46dJ2P4
el+bcV2mYw6FQiSXC4neLx+TJ0v41x+GtarVeqPRr9M40EIFxi1dtseALm7FOA/4MIDz4Bk3
HhtziBCia71S4FxjlsDcjBtc1AJYAHyYBcCHMRPD1/aU53URww4HKL8hP/mEEEJCYd28eVbz
4a4PI8+4gSHPtcHO8+WZGNDFrRjnAR8GcA+y8SKgjDm0BQ41Zs0t8cWJwgMOAz7MAuDDmInh
a3vKk7p+Ia33jR97apHP7uz0I1dgtuTDIR9GVGBEmYWCLrmcOmeB7ftiiS6Xx4AuZmPID2Xi
gbKxvmet5uYM4MMAzkA78tCZpiiHGrMcKirgQjjnwyjjY4nBseDDHIcNbRMyXGlP2RvjVl2U
2Q6xF8HDDp3ZF5t9WKtMNkHwPdGkdfm+4HvIrRjW6qJMy4kT8bwwVyVxd1CAu5/uYGwdZ2Ip
S41Gk5qaWlZWNmbMmIyMjIEDB9JutXbt2iVLlmRlZW3btg3Wce4h0BqvRuRP+7CXA7C2MYtI
c8xj4GGvngn7fZip8ZKic9+gWQg99lAmf3wYXr6ZnJKWlhYaGqpSqUaNGpWWlmZuw5ycHKPR
mJOTY+8eoT3lmRiX62qVySgVGPG8l7662moFxkUf9mrMd6ZzzD98vO3Rw16sPV8siQFdjMTg
b2kj8r+DAoqMM/FDmbb8Tp2Hmf4wsVhM1GRSqTQvLy8wMFCj0SQmJhYXF9PGR0VFyWQypVJ5
8eJF8GE8xtR7udB4UWBPYxZDbdIKuuLie8Mc8z0Zdvow+h/pI2ify+SPDzNFr9eLRKKkpCSR
SNTY2GguTKFQ7N69W6FQUD9oakK5uailBbdTTF9v5OTQpjMV05CZyarysEpXq0wW0ZGHHq0y
PDvorFwufOL0ab/OTsHGjS4v8/Lxxxg/X2+F/D+BQJ/47HcCgR6Xp/X0VaPRr/X01c7up/6z
sZTN54uFMfzT1REURKsL/0Y8Vh6ZrBV/SxOf/U6pNODv6itBxUJkWBN04GE5hcKuF14wzcfQ
0IBycwUm3sMlcMaHEfHk9wTgwziNJ70XGTb4MLL3gk4vgAJ7fNhjX1RBl9RY/LDTCyFkw5w4
fPZhUqn0wIEDd+/ezc7OnjDByqK6DgD3tT0T47AuSr9XhOTXh5Mc0s1waHt52NwfRh5ziFNw
d0K1utVqBcb4+WJ5DOhyYQx5zCFOwV/UO8aBH0nWPowWCoVyucP7ch7GxiVi1Gq1RqNJSUkp
KyuLiIjIyMgIDAyk3Qp8GP+g2C/PeC8yTPkw8phD8F6ABTzvw8yt/+CA9yLDHx+mfhyEUGBg
4JEjR8rLy48cOUJbgSHSQHzKe1uA9pRnYuzVRbZfQmQgvJc2K8sl5WGhD5voqzIdc0ieXZ7N
54srMaDLlhiywZo0qZUcoFQafp8LRohkvuX4Ya87xoG/V2C2zUfKTx/mJjAtOjIAAA4bSURB
VMCHcQiq/RIGeNJ7kfGwD6P0KMCYQ8AqbvJhlBGwRqMf5VdJ5IwLgBD9Cny2wx8f5nn43Z5i
T4yNumjs1+P9Xp4ss2d8GLZfeGFlRDzv1f2UaQXGwvPFuRjQZXsMUVEJBPrff5VCNG9eHZ4Z
h6jATPunXaXLecCHAZ7AdL0rBu0XgVt9mOlM89D1BdiLZR/mJGT7RVn2wVX2iwB8mOP0hPYU
G2LM6cJ33gcovzmHpA/nORR0mdovl5eHcR9GVGB4ZS+1Wm95YWVz+bgppqd9D5kqj5t0xcXR
zBRqy/eZMtdoUZHPo3XO/QoKfLD9KgsLw8EWhgeDD3Mx4MNYCOUOuxAZ4uR9WNUD5CYfRnZg
7JkEBOAi5nyYy8Fr8v3+v6tHCIMPcxyWt6cYL4+bdBH9XkJkiEPKRmFAo3xuVpbWY+XxvA8j
hh3iCoy8sLKN5YHvofMxoMuuGKLf62EFJhQK5XK9Wm3h6UyH9+UmwIcBLobSD9Qin81sp5cF
XOXDKJKh3wtwFe7zYe42XhTAh5mls7Ozvr6+ubkZPTpMlFeMuU89H3O3sJBV5XGhLjztenOQ
D0JIIqkVCrrmzavzKShgbZklklpsxRw+XxN9VWFhZc1BPhJJrRAZ5ow/S0y3wf7zxarygC7a
T2slEpfrqpw7Vy8Q4MXQayMiCOOFH810h67q6ur6+nqdTofcAPgwwAWQhx1yyIU448PI3otD
kgFu4XIf9rv98uycOLgycy088WFWseXYeTKGT/friaf9Byi/CQwyIoRkfhUWRt+xocxkHO4P
Iyow3OnlyXkO4XtoGdBlDtz1he2XUC73wHyk7qi3TAEfBjgIddghByeecMCHke2XzK8CvBfg
Vlziwx7r+vKs/SIAH+Y4/GtPMR6DB+DhCiwOKVvks41GP31BhdUKjG26bPdhtGMOGZnnEL6H
lgFdZLD3emzMoYvWQAcf5mLAh3kGSieQVHD+u/hdrB12aBVbfBiMOQQYxBkfxlTXFy3gwxyH
H+0pxmOwESG7kE7jwKLul4kfBhd1WfVhE31VAT5N6JFkyjTzLi8PfA+djwFdlEe+KF1fbNPl
PODDACvweACeOR9Gmd0R+r0AprDLh3n4kS+7AB/mOGxrd3ConUh4L/zwk+UxhxzSRUDrwyb6
qvDsjgghITL8MySHc2MOefY9tCumZ+oijznE/V7mpjpkmy7nYd6HaTSa1NTUsrKyMWPGZGRk
DBw40IFMwIe5Fh57LzIUH/aYag4OswT4B8WHYacllMl8zpwhYljV72UOXJ8VbdkS9Y9/eDt0
kTeFLT4sLS0tNDRUpVKNGjUqLS3N5fmzrd3BoXYi4b0OlDxjNR8O6SIgfBhNb9+j9b24qItn
30O7Yviqq2HqVKKLy1BUhBPJww5ZOObQNOa3wsK8+fOvHjzY1dFhdXMbYd6HSaXSvLy8wMBA
jUaTmJhYXFzsQCbgwwAHoCzCxGPHCXCU39fxwgiFyGCgBrHYfhHg+uxfcjn+t//gwdErVgRN
mOBMntiH0SxC42H0er1IJEpKSvrkk08a8f1c21Cr1Xl5eejBA3TrVllj4/I5c9DAgUirpby2
1dR4Dxlims5UDPrpJzRqFHvK05N1vTj2xvmaUcP6aWruBYT/4cbo6c8irXb58n9zXRdfz1cP
1PVESIixrc3r3j1DQIAXQobw8CdPneru18/r3r3ufv282tq6Bg3qmjQJabVo+XKWlJkmZsAA
dOsWeuqpgEdX726DwVVWjPk6zM/PT6fTZWVlaTQaf39/2zcUi8Wpqan4/QcffEC8p1BfXz9o
0CDLWXkyBpWUoKgo9pSnR+v6C0918fV8gS7WlMexmH/J5cK+fcctWTJy1iwvoWtqH+b7w6RS
6YEDB+7evZudnT3BOWtJi0gkYlUM+uUXVpUHdFkBdHEqBnSxOWZofPysQ4dGzZ7tqgoMsaE/
TKPRpKSklJWVRUREZGRkBAYGOpCJBR/GOpqakK8v04VwA6CLW4AubsFXXU6A+8OYr8Ncglqt
FovFTJcCIYTEYrFarWa6FAAAADyHLWPrXYK7KzDx41iItFyBmeaQl5c3efJkiUTypz/9qaSk
hHYrjUajUCgiIiLmz5+v1WppUwAyV69enTNnTlhYmFwu/+abb8yFWf3aOHbk4XzZi6vOF/y+
eiA8qcM8gJqEk5mQU/Lz8zMzMy9durRgwYLk5GTarUwfoXP3Q3VcJzk5ee7cuSUlJf/6179U
KpXD+Th25OF82Yurzhf8vnogUIc5jlgs3rt3b3h4+CuvvEKk2OsIP/roo5CQkN69e0dFRTU2
NhoMBmTS3iwuLl6yZImPj09SUhL+hZumAGSEQuGtW7d+/PHHgIAAfA3Cp2bkyJEzZ84sLS1F
jw6y5VNm45GH8+UkrjpfpsDvi/dAHWYrtPcSvb29L1y4EB4ejv912KLp9frk5OSFCxcKhULT
fIhH6EQiEX6EzjQFIHPw4EG9Xr9p06YJEyYcP34cPWqh//jjjxs2bFi5ciV6dJAtG2sbjzyc
Lydx1fkyB/y+eAzzz4dxBdpfDv5VvPvuu87kXFlZuXz58hkzZpgbWmn6CJ3DD9X1EIYMGbJp
0yaEUHV19aJFi6ZPn/7FF1988skndXV1BoNBQJn7wDyOHXk4X/biqvNFC/y++A34MKcQOv2U
Q25u7vr16zMyMlavXu3lRX86TB+hc/dDdVwnNTX1+vXrDx48uHbtWldXF0Jo27ZtW7ZsuXr1
alZWlvHRDKp9+vS5efOmhXwcO/JwvuzFVefLFPh98R6ejK13N7Qj5imJlJvstL7NNIaSUl5e
7u3tTcnZ9BE6lzxUx2O+/vrrPXv21NfXP/fcc2+99VZ8fPy+ffuysrIQQsuWLduxYwc+vOnp
6YcPH25razN3e8rGIw/ny0lcdb7g99Wj4NXzYQAAAECPglfPhwEAAAA9EKjDAAAAAK4CdRgA
AADAVaAOAwAAALgK1GEAAAAAV4E6DAAAAOAqUIcBAAAAXAXqMAAAAICr2DdVkoUZoxlc+JEo
le1l8NhKle7Y0VdffbV169bm5mbKLCHEvw4cEADgE85cqZhaxhYuSo5htw9rpPtjFgemsnb5
cTT3m3HHl3LXrl2ff/45JWfyv04ucgYAvMBz16qzZ88uWLAgNDQ0Ojr673//+/Xr1xFC+fn5
f/7zn0ePHj1+/Pg333yzvr7eciZwUXIMuJfIPerr60NDQ5kuBQAAD9m/f//SpUtLS0sLCwsT
EhKSkpIQQocPH16+fHlpaWl+fn5wcPCyZcuYLqYbYfCi5N46TCwWHz58ODIyUiqVnjx5EifW
1NTMmTMnPDx8zpw5NTU15GDTJSXnzJnz9ttvJyQkrFu3jkikLI5nb5FMl9GjLSftju7du7dx
48YJEyYQmZi+sbCjF154oaqqCiFUVVX1wgsv4MSGhoalS5dGRERMmzYNT19pufDd3d3knGl3
RIvtOwKAHkVtbe2rr74aHh6enp5OJNp+/Tlw4EBsbGzv3r3b29vb2tq8vb0RQocPH46Pj/f2
9vbx8Vm4cOG1a9fM7R0uSs5clNzuw1paWpRK5fr167dt24ZTNm/eLJPJzp8/P3HixM2bN5OD
79+/f+7cOWJJSYTQ2rVrc3Jytm/fjlfGQ3SL49mFOUtrWk7aHW3durW1tfXrr78m8jF9Y2FH
CQkJhYWFCKHTp08nJCTgxHfeeeell14qKSlZu3bt2rVrbSk8OXPbTbrtOwKAHsWWLVvi4+Mv
XLjw5JNPktNtv/6IxeIRI0bExMRkZ2fv37+fkn9GRsb06dPN7R0uSs5clNxehy1evNjb23va
tGnEwj+XLl1atGhRv379Fi9efOnSJXLw8uXL+/fvT15SEtdnERERLS0tOKW4uHjGjBkSiWTe
vHkajcZ95aTdUX5+/oYNGxxei4H4uuB7DjhRpVK9+eabo0eP/utf/4rvpLsJj+0IALhFSUnJ
okWLvL29Fy9eTE63/fqjVqurq6tPnToVFRVFvoK1t7enpKSUlJRs3LjR3lLBRckW3L6OM7bV
vXr1wkvbWaZfv36UlF69euFXYh28t956a+PGjXK5vKOjIyIigoj08vIyGo0OL/lqWk5zOyJK
4gBhYWFarbampkar1YaFheFEgUCAlzVyOFtaTA+Im3YEAHzF9usPQkgoFA4bNmzdunWxsbE4
Ra1WJycnh4eHf/HFF3379rV373BRsilPVxTMPsaNG3fo0KG2traDBw+OGzfO3s3b29v9/f07
Ojr27t1LTh88ePCVK1dcV0z6HU2dOnXr1q137tyhBPv4+Pz888+2ZDtlypT33ntv6tSpREpc
XFx6ejrR0HMVpgfETTsCAK4TGRlJXJQsR9JeFl5//fUrV650dnZqtVrcqY8Q+vrrrxctWrRi
xYodO3Y4UIHZvvceflFioA7btGlTYWFhTExMUVHRpk2b7N18/fr1//jHP+Li4p5++mly+qpV
qxYvXmy1F9Fcb6eNO1q/fr2Pj8+sWbMom//tb3+bPXu2afep6Y4SEhLy8/MJz44Q2rhxY2Nj
Y3x8vI29oDYqMj0gTu4IAPjKxo0bCwoKYmJirN7Iob0svPbaa++++254ePhLL72k1+t3796N
EFq1alVdXV1ycjIxwKGtrY02T7goOXNRsm8dZwv7gAeSAABgCXCl6gngdZzt6w+D0w8AAPuB
K1XPwe1jOpiCtiHGlW82pwsPAAAtnP5ds7bw9t1LBAAAAAA2gO8lwlxTAAAAAFeBOgwAAADg
KlCHAQAAAFwF6jAAAACAqwgRQjqdDmYxBwAAADiHUKvVEhNKAgAAAACH+P+pYcmKfOtUpgAA
AABJRU5ErkJggg==
--------------090204050809060404080601--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
