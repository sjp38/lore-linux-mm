Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 07E0B6B0005
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 06:49:33 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id e53so1234056eek.9
        for <linux-mm@kvack.org>; Fri, 12 Apr 2013 03:49:32 -0700 (PDT)
Message-ID: <5167E6BA.70909@gmail.com>
Date: Fri, 12 Apr 2013 12:49:30 +0200
From: Ivan Danov <huhavel@gmail.com>
MIME-Version: 1.0
Subject: Re: System freezes when RAM is full (64-bit)
References: <5159DCA0.3080408@gmail.com> <20130403121220.GA14388@dhcp22.suse.cz> <515CC8E6.3000402@gmail.com> <20130404070856.GB29911@dhcp22.suse.cz> <515D89BE.2040609@gmail.com> <20130404151658.GJ29911@dhcp22.suse.cz> <515EA3B7.5030308@gmail.com> <20130405115914.GD31132@dhcp22.suse.cz> <515F3701.1080504@gmail.com> <20130412102020.GA20624@dhcp22.suse.cz>
In-Reply-To: <20130412102020.GA20624@dhcp22.suse.cz>
Content-Type: multipart/mixed;
 boundary="------------050806060205040505050503"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Simon Jeons <simon.jeons@gmail.com>, linux-mm@kvack.org, 1162073@bugs.launchpad.net, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>

This is a multi-part message in MIME format.
--------------050806060205040505050503
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

$ cat /proc/sys/vm/swappiness
60

I have increased my swap partition from nearly 2GB to around 16GB, but 
the problem remains. Here I attach the logs for the larger swap 
partition. I use a MATLAB script to simulate the problem, but it also 
works in Octave:
X = ones(100000,10000);

I have tried to simulate the problem on a desktop installation with 4GB 
of RAM, 10GB of swap partition, installed Ubuntu Lucid and then upgraded 
to 12.04, the problem isn't there, but the input is still quite choppy 
during the load. After the script finishes, everything looks fine. For 
the desktop installation the hard drive is not an SSD hard drive.

On 12/04/13 12:20, Michal Hocko wrote:
> [CCing Mel and Johannes]
> On Fri 05-04-13 22:41:37, Ivan Danov wrote:
>> Here you can find attached the script, collecting the logs and the
>> logs themselves during the described process of freezing. It
>> appeared that the previous logs are corrupted, because both
>> /proc/vmstat and /proc/meminfo have been logging to the same file.
> Sorry for the late reply:
> $ grep MemFree: meminfo.1365194* | awk 'BEGIN{min=9999999}{val=$2; if(val<min)min=val; if(val>max)max=val; sum+=val; n++}END{printf "min:%d max:%d avg:%.2f\n", min, max, sum/n}'
> min:165256 max:3254516 avg:1642475.35
>
> So the free memory dropped down to 165M at minimum. This doesn't sound
> terribly low and the average free memory was even above 1.5G. But maybe
> the memory consumption peak was very short between 2 measured moments.
>
> The peak seems to be around this time:
> meminfo.1365194083:MemFree:          650792 kB
> meminfo.1365194085:MemFree:          664920 kB
> meminfo.1365194087:MemFree:          165256 kB  <<<
> meminfo.1365194089:MemFree:          822968 kB
> meminfo.1365194094:MemFree:          666940 kB
>
> Let's have a look at the memory reclaim activity
> vmstat.1365194085:pgscan_kswapd_dma32 760
> vmstat.1365194085:pgscan_kswapd_normal 10444
>
> vmstat.1365194087:pgscan_kswapd_dma32 760
> vmstat.1365194087:pgscan_kswapd_normal 10444
>
> vmstat.1365194089:pgscan_kswapd_dma32 5855
> vmstat.1365194089:pgscan_kswapd_normal 80621
>
> vmstat.1365194094:pgscan_kswapd_dma32 54333
> vmstat.1365194094:pgscan_kswapd_normal 285562
>
> [...]
> vmstat.1365194098:pgscan_kswapd_dma32 54333
> vmstat.1365194098:pgscan_kswapd_normal 285562
>
> vmstat.1365194100:pgscan_kswapd_dma32 55760
> vmstat.1365194100:pgscan_kswapd_normal 289493
>
> vmstat.1365194102:pgscan_kswapd_dma32 55760
> vmstat.1365194102:pgscan_kswapd_normal 289493
>
> So the background reclaim was active only twice for a short amount of
> time:
> - 1365194087 - 1365194094 - 53573 pages in dma32 and 275118 in normal zone
> - 1365194098 - 1365194100 - 1427 pages in dma32 and 3931 in normal zone
>
> The second one looks sane so we can ignore it for now but the first one
> scanned 1074M in normal zone and 209M in the dma32 zone. Either kswapd
> had hard time to find something to reclaim or it couldn't cope with the
> ongoing memory pressure.
>
> vmstat.1365194087:pgsteal_kswapd_dma32 373
> vmstat.1365194087:pgsteal_kswapd_normal 9057
>
> vmstat.1365194089:pgsteal_kswapd_dma32 3249
> vmstat.1365194089:pgsteal_kswapd_normal 56756
>
> vmstat.1365194094:pgsteal_kswapd_dma32 14731
> vmstat.1365194094:pgsteal_kswapd_normal 221733
>
> ...087-...089
> 	- dma32 scanned 5095, reclaimed 0
> 	- normal scanned 70177, reclaimed 0
> ...089-...094
> 	-dma32 scanned 48478, reclaimed 2876
> 	- normal scanned 204941, reclaimed 164977
>
> This shows that kswapd was not able to reclaim any page at first and
> then it reclaimed a lot (644M in 5s) but still very ineffectively (5% in
> dma32 and 80% for normal) although normal zone seems to be doing much
> better.
>
> The direct reclaim was active during that time as well:
> vmstat.1365194089:pgscan_direct_dma32 0
> vmstat.1365194089:pgscan_direct_normal 0
>
> vmstat.1365194094:pgscan_direct_dma32 29339
> vmstat.1365194094:pgscan_direct_normal 86869
>
> which scanned 29339 in dma32 and 86869 in normal zone while it reclaimed:
>
> vmstat.1365194089:pgsteal_direct_dma32 0
> vmstat.1365194089:pgsteal_direct_normal 0
>
> vmstat.1365194094:pgsteal_direct_dma32 6137
> vmstat.1365194094:pgsteal_direct_normal 57677
>
> 225M in the normal zone but it was still not effective very much (~20%
> for dma32 and 66% for normal).
>
> vmstat.1365194087:nr_written 9013
> vmstat.1365194089:nr_written 9013
> vmstat.1365194094:nr_written 15387
>
> Only around 24M have been written out during the massive scanning.
>
> So we have two problems here I guess. First is that there is not much
> reclaimable memory when the peak consumption starts and then we have
> hard times to balance dma32 zone.
>
> vmstat.1365194087:nr_shmem 103548
> vmstat.1365194089:nr_shmem 102227
> vmstat.1365194094:nr_shmem 100679
>
> This tells us that you didn't have that many shmem pages allocated at
> the time (only 404M). So the /tmp backed by tmpfs shouldn't be the
> primary issue here.
>
> We still have a lot of anonymous memory though:
> vmstat.1365194087:nr_anon_pages 1430922
> vmstat.1365194089:nr_anon_pages 1317009
> vmstat.1365194094:nr_anon_pages 1540460
>
> which is around 5.5G. It is interesting that the number of these pages
> even drops first and then starts growing again (between 089..094 by 870M
> while we reclaimed around the same amount). This would suggest that the
> load started trashing on swap but:
>
> meminfo.1365194087:SwapFree:        1999868 kB
> meminfo.1365194089:SwapFree:        1999808 kB
> meminfo.1365194094:SwapFree:        1784544 kB
>
> tells us that we swapped out only 210M after 1365194089. So we had to
> reclaim a lot of page cache during that time while the anonymous memory
> pressure was really high.
>
> vmstat.1365194087:nr_file_pages 428632
> vmstat.1365194089:nr_file_pages 378132
> vmstat.1365194094:nr_file_pages 192009
>
> the page cache pages dropped down by 920M which covers the anon increase.
>
> This all suggests that the workload is simply too aggressive and the
> memory reclaim doesn't cope with it.
>
> Let's check the active and inactive lists (maybe we are not aging pages properly):
> meminfo.1365194087:Active(anon):    5613412 kB
> meminfo.1365194087:Active(file):     261180 kB
>
> meminfo.1365194089:Active(anon):    4794472 kB
> meminfo.1365194089:Active(file):     348396 kB
>
> meminfo.1365194094:Active(anon):    5424684 kB
> meminfo.1365194094:Active(file):      77364 kB
>
> meminfo.1365194087:Inactive(anon):   496092 kB
> meminfo.1365194087:Inactive(file):  1033184 kB
>
> meminfo.1365194089:Inactive(anon):   853608 kB
> meminfo.1365194089:Inactive(file):   749564 kB
>
> meminfo.1365194094:Inactive(anon):  1313648 kB
> meminfo.1365194094:Inactive(file):    82008 kB
>
> While the file LRUs looks good active Anon LRUs seem to be too big. This
> either suggests a bug in aging or the working set is really that big.
> Considering the previous data (increase during the memory pressure) I
> would be inclined to the second option.
>
> Just out of curiosity what is the vm_swappiness setting? You've said
> that you have changed that from 0 but it seems like we would swap much
> more. It almost looks like the swappiness is 0. Could you double check?


--------------050806060205040505050503
Content-Type: application/x-gzip;
 name="bug.tar.gz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="bug.tar.gz"

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
d13nOof/Gov8P0lT8v9nDiic72T8J/tm8F9bcbb+b8L/Cf9fu2Xif2H8+p9p/j+a8v+N2Ab1
P9Fk43+1sZn4X578MvU/tXbD+p9C2TPif/0saDr5/1Q4Tif/HzuEplz/UxIU0//pkIMvm/7P
mmL9T6cuTf+nGFjUVdL/wbH0f9RP/+dsN/2flT5GuE3/ZwnshQVAk0NcFgBMDo4GALM9l6T/
c2SS9H8+hx1QHQAM2Kb/Y/g1x9L/+XiXYfo/n9+v3TOX/o93tN30f1pp00//xyifpv/z6Qip
G/8rpDye/o+sHqb/Qx7TJHb4zPR/atDVpv8jHOQGPCv+F9kDLKb/MwbM5fG/RmhbKgDqKWd1
cfhvJYzWhfx/Dtl8vmr+Pyd8OoXR8/91o381v5yd/H+gOvn/NA/elP9viv6d2htu2fpfr6j/
UVJO8T8jttP1Pwfqf0VtcLb+V6z1kKv/4XP8FPg/nzW5GP/rRBo33Iv/FWX+j+2aIv/nXLn+
h3Gj6n+1k+6s+F/SJf2Pr/8Vnks+/keV+D+QkfvM6n9j3deT63/Rmfpf/WbW/y6p/zXpfyb+
79Wbx39v0fFwvNg5PMgbo0v4L3zNTwZ+5TUGoH3+P1/4YcL/Mdo//Obb96vNt7v7my/3njpi
1255c/d44z/Kdz999+Of/+2vd56t+Jd/2v212ni72M++fdo+3tZm4+zfZ7UB+Y/VHr2fBXZ5
xj+LPHPyq916uXyaqR2fcbOcvvxXaDn7X77m+r9RU/zfiO10/Z89UP+vnP+byuv/XiJesv99
yu2OHZ+u/ytR1P81uXpy9j8qUdb/Uzn+31gaL/6fFOoYT3Ga/Q+WVCn/jwEVYxiz+n9VXv8X
KtYGHNr/XlVQsv951Ivxf8IKOJD/51D+b/lW4v/JxniKaf1/sv+/xpZb/x+//p9p1/8lhPX/
qf7HKK2//m9BZ9f/42J4v/6ftnq4/o9OD/N/W6Iz1v/BWlDd+n+6v/6vpHOky+v/YKXT+fV/
QFMq/wfKhUeRXf/HS9f/0TJIX2P9X+LhDOB+znVdAYAF0REAGKUFpAIA5+HnMgFAcogLBQBg
jwsApGszgAt2ImQrAACJts0AbkQrAEAbKtgdFACELNddAYASYPBQAnAp2WroCQCMRN0TAFgl
q+qCjQCAwPQSgAuDN8cEAFLaJNN3IwBwVbbzSwUArigAIHSD7ODnCQAkYL+rFgAgKGn7nWcI
AHwBopIAgJS7vP6fT1lbvYUZAQB/DWT7fRcJAJBtdRSjp//2opZUAKBMVwAQMs7XAgAp2Nd4
OQGAOioA0JMAYBIATO1gy9X/vjL99yvsf92v/zfZ/yO1vv1vQnntgf3PRmO2/nfv51Hra4f1
v7XQ59T/1hTs/UT/O6z/jdGijfW/cVD/22go1f9WsuAAKKdMqQBQvv63OKn+t/b22YsXAPL6
X9XT/9p++W/rbexE/ysk0oX63/YQF5b/luao+V/ZJY3+l7rlvy2/MJQt/82vrzpi/hfKf/P7
Rgf1vyoYzmn5bwN985/txUpf25T/tlRZ1Gn5b2uP63+1TmqEt+a5F72/aPlvhH7nueW/Xb+r
Lf8NoW7OpeW/retrfJvy31bg5fpfhxr6Et9a/os+idFV5b/ehVevX/7bHS7/jcZN8t/J+p/a
W24Z+1+7K5/jJP4fA/8/5f8bpw3i/1yW/0eGnIz9r0SoztmL/yPAvv3Pdpk83f73Ethu/B+a
8HfK/5MvElDm/61CLfLmv4rxizn+32kqxf/pcC898x9Pqf8p5Tjmv/fcuua/wy77zy6cwMT8
5/sWdUHQM83/9BCXmf/iV5j/WqT1PwVVHHo0/zX5bAG1+S9da//HEThs/yuphvU/fYIU2XoO
GfrfJ7SQHfufPQnZr//JFhKm9D85UdUDTeh/DfrmKP1vMvU/ocoCebH9b1S/q7H/nYLr2P8I
smj/+xzYst95uv1v2QYvxf9ZiY5uLrX/Gb18KeF8+c8q5OCq5T81Ir0C/697/D9PkGn5TyUp
9QCUr8828f+TBzC1t9sy9r+EK5/juP2f6H8p5v+Y8n+O0nr2P1ntsvy/0zpj/ztl3dD+9wkl
Bva/Cik6TuT/bWUdpPY/SNXn/w27CeX8H87nAsub/2yClcx/9kChyP6Tu1D+Iy162+/lzX+j
25WRYP7rMGKN+c8D4y+9Zf/BegL9IvY/OcRF5j8KPJr9QwklW/ZfO6iqyUfzX2jr9VG1+d9m
//ADQObmoPXPQ2rajQ37zzvqg+y/9nGBHeufJ78qx0XK/mutZcr+SweVwZ6w/1qbm6Psv6CM
+Ic/HEg2n2X9C6up39VY/6DI9DvPY/8Bitk/pC8sewX2H1H2e2rrH8FUTuBl1r/Xedu88a+d
Cxqu67H/oJS1o7P/fpEksf3915Oy/6by02rb36cgfDnTn92MjulPQ9M/Y99Ppv9k+k+t34b2
vxGj6/9BtPk/VJX/g2DS/4zS+vw/BKp8YP9DNv8fGUcZ/b+QA/2PluYM/p94mgwGbGP/e6up
x/+jpVT/0+f/DfsMBQeAXzRX4v+NC5ZyxgEgnZP/wCn8P/ps+y/vAGgDqpv+zyjE1AFQXsqR
pP9j+/VSB6BziMv4f+WOq/8JE/U/ycAYRwfACBSt+l95yUrN/6MWxzwAxyZwS/TXHgAgv26H
PACeQq3u8f9sacoe/49OUOsBsMmkjezJ/9l/O+YBOJCYEP21YStB60Q7dJYHgEIX5f/Ic7W+
hgeAytJA4V97AI6fP/Q7T/cApLBS98382kAXXp5/sQsAAiDEQ2QWAIAdEOo7CBc5AcTTkx5d
AuR6GQANz/PpAkBYemsWAAx/YPLFvACQXS/ADrwANUmAJi9gagdbLv/HtROAn1T/M+T/Njjl
/xilnVz/I+aryNb/RCzk/wNZ17Ie5v9AK6Qo1f8G6tXjTPJ/IJpi/j+pYo6/XP4PFetV5/J/
oJSl+l+8X8iPMU7+Dyl1rHN1Wv4PJI0xn8og/weBizXFMvk/qM7AkMn/QWxIl/L/MYZBqf6H
trGOZyb/h3Tozsz/QW+l/ie5WIv0nPwf0k75/6b8H6/bMuv/107/+yv4P9nP/0s46X9HaX3+
z/YEvTX/p7TJ8X8+d/+Q/0M3WP9HV+tjT+P/yJqu/teKgf4XfXz9If5PQiH/hwQlyvyfpBL/
F453Cf8H5Beqr8D/BZHyAQLQhmQsLQEotewQgEoLbVIC0CdduZAATA5xIQFo6VcQgJAQgDzX
JAoAIqttIwBWflW8JgD9EMgjBKBytq300RCAIJ2zhwhALUUVcJYQgL7ORZ8AFAJSApDdfdUN
AOTLVzfHJAAOcCgARsEWW0IenkUAgoRiAZD/b+/KshzXceV/raKXQIKYuKS3/w080pQtkgLl
qyFVWeeQp3/6umynJyEQCERguqJjf+MpAnB5F2wC0GO8wf/Du/RhDxTAlN53vq4BSF9UCgMD
EA9ZZH/rDiBnbfTzCuBuB1BcEwES6BW98yEAOaE6/TkFsH5TAKdf0yQAJwE4z/hY/J/8xfwP
z1jyPyb+f+Qc5v+WLt30/114GSv/I5KO8j+8Ls9n5X8g8Tj/Y8kisfI/wFPr41vxf1nZOOL/
ALvckCr/Qwme8/8lyUtDbyblWP4Hx0H+LwIsPsxm/gcuf6eR/4HLa7fyP/SdDWLkf3x4Xyv/
I5Z8k8P5Hwi/KP/jPP838z8m//e3j8X/Pb7/H+r8r+L/RVP/98jp+T92tv8vKJj6v+LO1fN/
RY7X6v+cO8f/xcb/C7kYETf8XxThPf5v4eYO8n8aR/v/HKz9fzik/3PLO3rZ/xe+EoCoHQEY
OwJQU29bE4Cvqn2NAKwe4hoBGAohvU8AvvbUPwQgY00AKr4W5A0CEF2t47MJQIKwdQALQZBW
7aBFAKZnbXeAEhKg3gEAA774vQ8BqAG6BGCuU3wHCkCnsZL6fQjATF5eJQCLQ8FAAejcLQ4A
mC76QweA9CLkFgIwAUr9MyAAKQt6LxOA0ecrxkAB6HylQLyFAExflr+hAKROAehaBeBLFLoS
gET+By2A41cF4CQAJwE4z84x83/x3uc4lP+76P947v8/cg7zf6FwPSb/h4WPs/i/bBg05P+C
VHq8lv8jgBH/h+mPGfJ/BDLk/8D7Ef/nY8Qx/+ee5P9YnOqJ/K/084VFT7nl/wJQ4T5t/m/J
+Dqa/7tkYJn5v8yj/C/yi3bueP4v/Bb938z/nfzfP33M+g/3Psex+l/mfzTzfx85h/M/XREt
m/Wf4rD+k3efGtjVf6fsRvmfIN08rpn/sVZ7A239Zx3nf/owzv90JKP8z+xGjw/Wf6UlF9Wu
/+VqadR/paWuGvUfXZRx/XdLHbfqvwz1/5G9nKr/jtzJ+u9m/Z/1f54bznb+R3eX/+/zP7/m
/ziEmf/z4NnO/0z/PwllZtTO/4Ik8GbM/1J/1s//IBIcn/+Je9vwved/XrnX/+eVRKn8/6Cd
/7HCSP5Pi8W35f8HEkb2H+iujv9SgY7ldfys/Ye4LMBt/P+wOLZ8/P8AFOvwT8FIbz/wk/5/
9UNc8/8L8tX+O2/RfYZ/mF/wav+hgRjwPftboz/z218J+M3JH4Ho+k/ek79sJOHWgeBm8pc+
1vxbaSZ/7Jz22T/+Fcv0cf/T1O9Q4/2dQdW3wR9rGZy1g7/8efJF6+88ydr4+70Hf6BKG1/w
M4O/BKhp4+79fqdJYGMMeML7zxH4P+bYD31cskUvjf0QAftb3u+Ug7K/cdvQDzB9dR9X/YvE
ZugXpFH9g+M6+Sf/AOTnvP/8N++/6fo9R37z/Ndj8X/uL/J/jsL0/3jwHJ7/QeGITP4PCpdl
+H9A9nK2+b+Aeel4wP9h+kKO+D+iMPT/yNt4w/kf4VD/72XH/yMuf+cz/h8hteLyZksOzP9C
6spooP9PbyaWfQqL/wPwI/5P+D2/3fJ/nNv1Af/H7+/Llv/7X3z7eNj8X2GKTP8PKfPiX8D/
sUBh6c7wf9BQh5P/m/zf88f0/7rZAPjQ/p8v9Z+m/ueRc3j+F3b8v4RH9d+lH/hA/0PEjY6n
qf+BQIf6n0A8mv95T+396voflnpszf/C4ilmzf+iPjj/SyicoFwRj9X/9IA40v9QXqcY7f+x
G+t/8ib/aP6neYFnUP8py9AH87+E3sprP+7/VXDRb6j/EctrmPO/Wf//xWPu///F/j9d90r9
n/v/j5wT+p+h/jfdNqj/oDKs/+JVdKj/CWHs/5m+VXUdb/Q/LnZ7/PX+P47rP2AY9f/+7WHw
0P5/euXxRP+f2mMa6n88Ao/8P1PRCaP+H8GXq7q5/x8XbwBr/5+G9Z8gnNT/LjqsX1D/BRc+
Zdb/Wf//xWPt/99ddw/t/7tF/+Nm/X/ibPJ/VC39DwUz/zMVFCv/x7tt/k+OCz+x/5+BQ7v/
T33+J6CkK/HO/j9wiLYAKJVDGgiAgrAO/T+L6umK/2cWUeg9+//0Zf8/FvnTuv/vilvqZ//f
R+cbA9B0MYaLBqDVQ1w0AP0uAfIcVgkQpxLDsdr/D9H7NQHIVQlAEF/ZQLv7/67+J5/9//SO
vVa9h/v/OVOJ2v1/UO4TgLIFaaj2/33+0rX7/6T455sBaIKRldPnZ//fi1b/+NT+f577DPf/
6eUGeUMGqNQP1C3Op27E3ZAB6p1PaHogBMpIqxcJndj/z26YgxTQ9CN1MfTxQNf2/90r1/jp
/X9t9/8TWGgNQF1jAErp+/1zWiCQrwagMwd0ioHm2TkW/wd/c/5X8P/U/zx0DvN/rMP5n6fC
nVn5Px9vyW3+D3nkEf8XspJ8xP8xjOd/QXDI/4Vlj9/i/0hotP+Xr8VP5v+Q07DD/8lg/w8T
MFvyjbb5P/zWMB2d/8nC+1r5P6nKj/N/FhbLyv/h5bt0fP7nfov/J0fvTs//pv5n8n9/+xj8
Hz2+/wey1v9Q/D9x7v8/cv7j/h+KGPt/kNpzY/+Pg/Mb/m/JzDnG/1H2MGz8P8lt83+yVMaP
+T/1WP7KLf8HocQaWfxfnoYN+D8qb1LH//kj/J9DeCL/mx1Jm//NqlCzf9nVHH21ABiD5gSd
KwuA9UNcY/8SJPnK/hFU8T+YEFVY2T8KEYTf7F9CHCv75zBz2rvsn3rxK833Zv/yMJRWUnDL
/qUvKUC7AygxxC7+ByMLVjuAMYemd/nfmZ7+xv61GUFvdo5psWK8wP55x5s9v/fjB6Xg+xtP
sX8I24SfN23GeU/yOvunIe+j2uSfcGGPL5J/Lk8qBuSf4/IlvI/8S1del66LT5N/2JJ/RNiQ
f75N/wFQ536O/INv5J+fm4CT/Jtn/xj4n/3Nz3EI/yMV//85/3/kbOb/BCb+52D5/wdHuMX/
RBA3+F8Kmj6K/wMUXP2Z/0sZXrf4PwGlPfyvFcpv8f/STdj4n90I/xfvjg7/4xH8n+3LbvH/
/4r/uTMAidgagMSQsyor/M/uZbtxBf9XD3ER/9P36X92m1mn/05eIPqN/9P/W6f/Plb4P30C
Gr7gfwi82vx/8H/ehdyL/8yKk9esv5r+O+XOA4TSbwfW6b9GAdHGAyRbxvN3/K+v4XWH/4VQ
qvuew/+LP4aJ/yPRLe7/WUcwnP6LrzMGzuN/hVcjZeH/9HHyDfg/X5hG+N+Dit7qA0JI2XDo
afzPbfoncWzwP0CD//OPd+L/if/n+cXH9P/4i/N/R1T2f6b/3yPnuP//jv9HhEH+Z0hFduz/
ka6t1Ty+mf9j8Dj0/8jawMH8H947qab/BzS+wa3/v/Oj+X/IIZjPzf/Dxx//oP8H+uXvNPw/
UsGB4f5PdrMYzP/FLXuupv/HOP+Ts7nzYP7v3JLtenj+r79n/i/Lzvuc/8/5/794tvyf+Mf5
v+DX/R+Quf/z4On4P3YlptPY/1GD/8tqkS3/F5R4w/85xFP7P9mItOb/fHnGZv+HCWjM/wmK
DAyAfbq0D/d/YolCtfZ/+PL+T34/6Of5P6KKGi3bP6Bt+mee5IZ6+4fj6+28sv1TPcTV7Z/4
H7Z/4sr/cfCwGgB7SSiR1u0frLZ/0icg+/xfwoJI63/8bP8QBt3j/0AhOm35P1TCjv9L6AFj
tf2Tyv7Lu7hO/4xf+b9I5fV32z/5W391/k8+DE2AUV28J/0zvZkbo99P+qfm+Nfr2z/eSYA/
JgGYXiTekP6Z+hR8ccVm+md0wfXRoNe2fyh7+T1NACbIDm38Z7qG1QygvDQhHwZQKF8pf4oB
DP5r/GeYDOBkAOfZOQb+d/Hm5zi0/w809b8Pno3+F039L6E4C/+LGvv/Ifrt/r+DE/pfTiCj
1f9i1nBu8H8E3cH/BAHP4P8wmv/fgv9dEUlfxf8lzmO3AejW/6F0Q2sDIDkko24A1Odu71ID
sD7EtQYgwfnvDQDxTgOAkIf1ZgPgFP98aQBy1sG2AUhobv3PVgPgkLr1f9TXdLRtANwL338a
AAg5Xv1wAxCMFJDUAICvdMGnGgDUrcb30wCIvlJNbmgAQDcYf20A8vfojgYgvJo9swEAEvlz
vQFIb0n8M2gAVFX6+11sAIg9/4IGwO82AKj+5yQAswGYDcA8146h/3WP+395rub/L/9PDtP/
+5HT4/+oYuF/Tvhli/+zCjBu8b8EBz3+T5XhBP8vLiG2Bv9nh7IO/3uK6N0Q/4tXcjb8p+V+
Vv5fWAYNVv5fsNb/jsB/jxzKg1yF/7Av/43oYoP+maBd/8ubYhX6V0lAxcO1/L/qIa7l/9Wf
6yj/D17mVwX9U7rOVOg/uhw7beT/ZTm7/NnV/iaAFbe7f94xwg70z7mC6QvSQH/26riF/hjS
L01W7a9msXnr/OWK8nUX+qdvom61vxCJaknwqQDAWLTIdgBgNNIBz0D/1GD4UQBgFIx3BAD6
8hZZ0l9IF6rrwJ+cEv0xcX+IGPHeAMCX4fzTsF/z21Shfkzf5zoAMLyGK2/Unz1x9cdAv8dv
AYA6Mf/E/PP8t2Ppf5XvfY5D/l/CL/2v+In/nziH9b9EY/3vkrlj+P9LUBr5/7voiu7U8v8X
Hup/Qyo0I/8vRzrO/8kZuiP/r/T9a+9X+f+nt+U5/y9KGJqKrvag/79SGOX/pc5l+Yws/a8u
eYOG/jf9Nof5f5FBRv5fyIsa1PL/T7/8Hf3vjv8/6m/R/07//6n//aeP5f+PNz/HMf9/nvv/
D57N/n/w5vy/Xen/zP/z6HHD/yE56vk/XIjFw/pfVyb0n/m/GvpfDTv8n5dANPD/8uiH+/95
VWY0/w+X5/+pZQ636H99kT7s+P8vauxVAJBQVSMAAAhZ9bEKAAIIXXIAaB7iogI44jcK0DPK
KgAgda72/ycWYtP/P52of/b9/30M6z/5CABAXFj/rSEASLCgKIdXAUDw2AsA0ndMagUwOM+9
Avg/OABodrHb+v/nIISLAoCQavlQAMAhcn/jKQeAJYbB9v+PMcT+xjP+/6kFGfj/k/Oee3uA
ExYA6XsHvcX/x/8/c+L3CgD8y9nicf9/6fz/WwEwUc0EesqmFtP/f3KB8/zSs8X/FPXm5zg0
/8cF/0///0dOj/8XQNzjf/Hlv3fzf0Jn+P8Su83+X2oU/Kn5f0IANf73Ufr8L0+aA4SG838g
GcR/EZZux5z/I4zgPxbn3kvz/7BoiK/Cf/7i/xURW/TP5Jv9Px/CSxC8CgCEXfDXBADVQ1wT
AAT3XQDgX0i7oH9ULdZbBf3n7VEBSwAQ5Jv5bwZYWwGAi1Fe0/yhAEBfaXStACBrsFsBQOoH
Ku2vphNez/aB/lHd1+QvAV+LBD7z/0CvvubS/J/8cPcPotA983/wMEL+Ed1WG3Bm/l/eInP+
z4D9VuBx3I/qRrrfkHpvunXvLxdGeHzvL/v4tvP/JvUr8wf1/D+HeM/5/8T88/z+Y+l/b7b/
+g/+v673/+Iw8f8jp8f/yqb/L2cD+y3+T7U1bPF/gm244f+Fzvh/JPhKjf9H4I3/r2fRKiS2
x/9KAQf2H5Sw4wj/k0c/wv9k4f8j8R8+609vwf9lOjLG//kn1eF/btb/fMJZrBX+T3Am/XmX
8H/9ENfwP3D4jv+DXwXAOUx29f+NEtg5A/9zKLLQHfwvqZfYmv+mpiD7Qo+pf+ez12+L/wNj
LwBG//Il+Zj/OkofQysAXlSVuw1AFMP8IzVNJaDkCvWffvIbdv9j/uuQsb/xFPXvi5rapP5d
6v5uMP9lAOkNft8dQADvb1AAi3KP8t/PwFjyaO7rAFKH+xcUwNDu/WXipO4AiOu9P5Go8ec6
APrWAcTZAcwOYJ7/ciz9b8Let55D+l9f9L+T/3/mHM7/jTLU/4KU2wz/X0dQlH9b/S/nb8NY
/4u+8fGt839RymNa+t+g0vr4VvrfBAjq+zX637AoFK38X1jycZ/R/8bM7p7w/yWFJTd4q/8l
SICHh/m/VJ7P0P+mpqH4Phv6X9VY/JSt/N+EvUb638DgzuT/pnet/J2/QP/LOSVy6n+n/vdf
PVb9vzsA7FD9x8X/f/p/PXIO7/9gufaa9Z954P8P0WEc7f+gLI9p1H+PS22x6r/jsiOyrf8u
pqvQaP8nMy8j/3+AiKP9n0/tfGj/hzB+rpYH6r8kzLS8vk39zy4M4Eb7P+89LKP+I7x3fDb1
H1wqg6P6j+pguP8jS6aAXf9L9TPrP/Bvqf/pJZS/c9b/Wf//xWPUf/mb+T/pIlvq/9z/eeSc
qP9uuP8Lo/yf9J2COOj/JdXcWPXjXf+vPN7/XXZZrf5f/M7+L/mKb2jrv2Md7/8u9fGZ+p/F
SWf6f87OKcP934yMhvu/bvlbtvUfIiyvwdj/FReG+7/klp1io/5n7/pT+7/8a/J/Uv2Hs/k/
Wco66/+s/3/1WPnfj/t/1/nfVPT/PP3/Hjm9/oecuf+b2nAr/5scGv7f5IqsvtsJOJX/46Xo
ZNb936Itqvd/KVAVE/M/7fd/iYqHuLH/K2Ho/62BhvnfRexzZf/XM2i4QwD0Nf87SKv/iUUy
9Nn+TcVbm/xvpby0dyn/u3qIi9u/+FX/49+Of2X710emdfuXVJr8b63yvznAlxUAxQhxIwGC
BEmrzQAj/zumq5u0279Z0tht/3r2Wq0ARFV5LRXX+d/0ffsXuBb7vyU6muDjxR0A8BjH9t+p
WNxi/51+ZTSUAEnuG65LgGJqFQbxPxjzSPP68m82eOfB8m/6hoL2m8HX8r8lbxs/vvwr7RoA
IzbLvwFcvfyLLn8zf2z5F78t/3qZMqApA5pn91jzP7nZAOjQ/C8B/8z/8fT/e+Qc5v8Eh/O/
N6Fh8H/KssyBtvyfR/FD/i9IbPQ4Nf8XsZnjNfzfm6e0+L/3LNKc/4U40v94XeZxD83/gl/0
Rkf5v4ALL7rl/7wu8ypz/heKl501/8sRJiP+T/14/se4cIMW/7fotw7zf+E3+f/h6fzvOf+b
/N/fPhb/F25+jkP8H5b8b8JZ/584G/+/kvO94f+YjP2/vFlj+P/lJawN/0d4Iv+PImSHqZr/
E449/8cOyI/9/17XFpv/A+eG/n8xxNECIJUdxI7/w0P8X1DAR/g/oo7/ozYAJKKTev8vcmHd
rvB/1UNc4//cd/8PT271/8juJmHd/0soKl1odOX/uOL/0ifAf/b5v3Qx3FqA5P+IKy1o8H85
9zi2/J8rkRk1/+dYXtl2b/5PsFjE1fwffvUAUXD1nuDHeSJhzuofn+P/AMcrgFFwQw6e4v+y
/G/I/4HjG/g/jeRG/J+mi1W/HniC//OxRL6b/B8ChT4b/Br/h5qw8+P8X6awK/4vtSgN/9fa
gKR6TiH8HP8HX/k/mvzf5P/m2T0G/r97/e8Y/veL/9/k/x45Pf5ndRb+J2LL/5siW/if/cb/
O+dxnJj/58XBxv+PFvPqGv+DuNXkbov/kWSE/4OPQ/yPbjz/d5b/9xEDkOxJSLcYgPhvDoDo
sYsA1NB2AIIMTQfgBONFBUD1ENc6AIzxawcgGNcOwCOGsHYAgVIf9/H/llUAAKROv4QAqg8v
4Ng1AN5r5R5oNACpqeJWAJDd5DsBAGpqb6sQwJheamw9QHxJv95vABJM39p/54xyumr//bL3
GTUArHyLCWDAYoxuNgCYhxHXG4D0KMMGIF3xuE8IPN4ApOIZ3EAAEL2mNvRO/I/ZnOb5+b/v
8H9rAhJc8ap/438PmZaZ+H/i/3l+7THw/93j/2P4v8z/07Vl4v8nTo//MZj+3wl2Bwv/LxrZ
Lv9Htv5/RAXHHdX/pvIfWv1vseVr9L9OCcf4X0IQb+P/HDA0wv8Sy6sw9b90Wf+rgO4O/P+N
/w/Y638jt/pfweztuKL/SKLX/L/rh7io/60GO2P97xoAzgQeav1vJBrpfxUI/uzDfwrB4P/j
KwB5J/3HqRPo9L85yrzl/xOkcLUFYCT2Pf/P/s83+B+aHuGTPO1Yq67gHPwXt5H4fvS/GLbi
4HP6X4hD/l9d2IqDT+h/CXAQ/oPpquPxz1X4D4E99zd9+H8hhL43uKj/1VQsn9f/tiaACS60
+t+XD/qq/03vLf8c/uev+H/aAE78P8/+MfC/Pp7/E1yV/+le+B8n/n/kbPb/GE38D0Xy0ud/
Chv5P+i8bvA/FGHRQfzv83Zag//z0kmH/5EU9vI/vXej/b8MDkf4n5gH+J/h8v4fcOQH8D9J
RG3wf8J0bfpnlgRX+D86eBHKl9I/q4e4hv+D/w/pn1Snf4LW+h8OLq76nyb9E6TkhO7h/6iy
pf/TderVU4zxfybHu/0/KLt9TfonRL/i/5iuegG79E+SrxbgyhKr//pJ/3QRrtL/wDRO/6SI
0N94Cv+nbyj3N33wf3oftb/xTPqnIz9sAJTxhvRPBrfuGPbpnyEC9RlB19I/nROHz6d/dg2A
xqYBwNgIgIjU/1wQ0Ez/nA3APFePgf893/wc3/l/XPN/ZMH/0//jkbPB/zFa+J9zpskW/0ct
Sp8W/2c/zw3+Rz6j/1EMvtX/4wb/e5HowxD/R0IawH9yYST/Sf2OH9H/KFflP15lMVq5LP/x
cX8AIBRC0wAwl1HOR/5D+LIiWQOA0kfl9FoAUPUQ1wKAHH9tABYB/BIAlD43iGsDkK4nMRXR
9wBg5f/TR8D+i/xHolgRQOQV1/AgIwKIRLJUoo4Ayn9WJ//J/ypW/D9gmRpUEUCltdnH/w7A
4P+9qtJF/O9UNxD/I/8Ji9/FZfyfDUBG+D9harkjAij9YkfyH0Si/l7H4b8w4kD9w3mx8dYQ
0PSWpSL9eARQ7pLqCCBpQ0BFa/eP9KuknxP/+47830YA+Yn9J/af5+sx/f9vNgA85P9R/P9E
pv/vI+e4/6+O/f9d8Z2w/D8U8eOB0fv/hiUjxvL/AMXGx6Px/3dU+3g0/h8OYej/H+OO/z/6
Yf5P+l7ik/4fb89d2/+j+GoY/v8OFu98w/8jweHyXtv+H0tGk+X/73Hg/wHOve9n+X8snimW
/0fAvfyfPf+P4lPyO/w/aOb/TP+Pf/ZY9d/fbABypP6nf1j8/2nW/yfO0fovGIb5fx7doP4H
SJ/oIP8nSGz8+Jv6H9S3eTxV/SfvZFT/vXga5v8FLZ7tpv9/lzdU138Bes7/P+Nw0hP+/0HS
b+1THdr6L6nqyCj/jwRwlP8n6TfpBv5fzO9sh239Z/fGDdv673i57WD+H8cl2/EX1H8WPZ//
B76+66z/s/4/f6z53+P6PwjV/K/s/+Cs/4+czfzP9v9iR96a/y2Tvm7+54z5Xzzl/69h0RJ+
5n9Uhm/N/C81yjqe/zFxGM3/hvK/og4bzf8s+69j879UG+SO+R/At/Efd/5fjNqO/whDrMd/
5FNrfm38Vz3ExfFfJewcjv/86v9FQhF9Pf7LH785/oui+m38F3Vd81/Hf4y03tMY/3GOS27H
fxKY+/Gfqqu3/7OtmLTjP3ktxp8a/8Uo1X3Pjf8iDOV/IejWG+zk+E9xOP4DpRvsv9I3YGj/
jwmjXbf/F9HR9g9D/vTvHf9pxMe1f9qZf6HEdvwXQz3+C+ln+XPjP/26++Pn+G+O/+b5eiz+
j/7m/A9D8f+f+z+PnOP+/2XuNMj/doP5X0yf8Yfn6vO/o8Bo/ufBwXD+l7f3bf7Pad6PHc7/
Wt6w4f8Srhnnf9Oj/v+Uoetx/k8gqhvwf4FFYTz/e2d1H8z/5nc26MH8b4W9/M+9/G/8PfO/
JaN1zv8m//cvHoP/o+f1/7X/vy/+P1P/88jp+b9o7/8ii+X/6VGN/V/SuPX/ET3l/++cNv6f
uHh5Nv7/GVyM9381LOvBhv8/BD8gAEOqvkP//2AtAMCR/V8XSfgJ/5/FuLXy/ykLFR/+TzVg
4/+DCQLSNf+f6iGu+v/LN/4vb3Gs+7+ooZb/U34DKvm/X/d/XSx82679p3jD/4d81F3///Sk
2Or/dUmZbPz/XTFMeROAHOJm/9e3jJ9FAPq8CLohADkqXc7/LPsINgGoUe4hADG4IQHITGFz
vxP+/6xhtP6rTja3nVj/dRKpZ/k+/j+OcbMbfM3/BzjBx8fXfzOTXvt/crMBEHxDAXqgzBFP
/8/JAc7za4+p/7u5ATik/yv7vzL9P585R/k/4MK9mPq/ULgQS/+XvliD/M+gSDLK/0y9YavH
q/V/Idb3a/V/ccmdtPR/uGjLLf7PKw31/znW6kH9X3p9p/R/mn0zx/q/wtGa+j+Rkf5fnA8D
/s+zLLrPo/o/2eX/9vR/5X35BfxfaovL+zL1f5P/+xePuf/3F/X/S/5n+jNm/X/iHN//25n/
uXH+d2Q3nv+FMNL/+7Dslpn7fx5rHX89/4t+rP/3yjCs/+nWNje8qv+e/JPzP4yed/b/duZ/
UN4zY/4nTnRY/6Mb1n/8zG+N+R9RyVM/Ov8TKq/v+PyvfM9+Qf0XxPIa5vxv1v9/8Vj5H391
/pf/XZ7/yaz/T5x+/rdo27f+vx6N+V/6PRv5f8jBbeZ/7OCE/t8Rl4SRNf9DjPwPhzv534Lp
fwP/3938j6gj/193Of8DnBbPsh/2/9Xls6j8f8sAdc3/eHmTVv6/6dcZLs3/moe4mP8h4ev8
j1+xYx//3yJEfvv/Oso+y1b+R/oEqJn4GfO/rIbYzv9iJiB25n+Q58rYzv8SHO38vwigxIh8
8j9UXv6pjf/v9/nfkl/d539AeEnnr+V/jP2/EEluyv/Q7Yjv4/+bIff1+V/kksdu2v8GhesL
AJB9IHqH38/8LwLovfkfGuJfyP8W7vI/tLX/fcXZrPkfnPqemf8x53/z/N5j4X+4+TmO4f/F
/3fi/0fOZv+3gHAj/8/a/00YRgz8r3Gb/70g7aP4PxBLi//DJv+DwMFe/h8GhRH+xyH+V1fu
Zeb/8VX8n0WEz+j/wib/z7X4P/3oscn/yya6F/P/1oe4iP+/2/8m/L/a/3LW5lX7vzlhO7Kd
/5c+xvAF/xPgCvRX/J/Q3npPK/8v0GsdtMb/QXr9n885KTX+h4Lka/z/H/x/IXJl9PvG5xq9
v6z/y2bgQ/zvdHPjOfzvHfQ3vZGzRE83+P9GVBnif4/uevx36vfI9ya/a/5fugbdnP8n6er7
PP73Hf4Pbf4fN/nfGPLv7cfwP33F/zrx/8T/8+yeLf4X9zj+D37N//Ov+T+Hif8fOT3+5wH+
h2jx/4xm/rcX2eD/9Jme4v+lw/8kW/zvoMQQFvyPPf6nSIP9H7/EGtr8v4zwP5epxxX8jwhl
D+cq/sd9A6BsI9wFAAJg0wAEn36e9QCAsunytQFA9RAXG4D4HxoArAIAOa+lrQ1Alli4zwIQ
YBUAmD4C5//sNgAJWoftACAglFiKYQOQ7vbyzqkagISG+gBATH8s/lkDABNeom4AwN8DAKN/
TTj6AEC/BKFfaQCW0YLdAKS2OvQ3nmkA0BeXJbMBiOn3fksAoIj0Kd/Lc5B12/EOILhsVTDo
AEIIoreaAHEq1s+bAMW8xFZ1AOK56QCKz9KnA2AFhB/rAIJrOwDddAAAswOYHcA8O8fQ/1K8
uQE4tP9T9v+FcOL/J85h/W8Y7//8b9GBGvs/CbfjaP8nfxlG+z/sdez/wzTM/yBH3Op4V/1v
thQd5X/kjmCk/81Ck+fyPxhVaS//Y6T/BUGIg/0fTa+uaK0N/S/Koos29L+a3rbR/g8FGvr/
MLxv2+h/E3B3e/kfRSlq7v8sj/kL9L/81mif2v+Bff1v+WZM/e88P3eM+f/z/B+4tf5TKPzf
3P955HT8H7uB/3cIhv9Prmxhy/+JxI3+F0HOzP8jgGv8v4OjTf4vK/NY/6sIbkD/UQAc0H+A
MY7ovzz9vWb/49nF8oZepf8Wu6bh/D+6gA39x4t50cf/J2hMXXvl/50QOV2i/5qHuOb/DQjf
6D/wC9/3f0WSIq842UL/ZU8d/ch/3er+nRPi6M+++7dp/uN9Dl/d4f6c9xg79+/gXp5Etft3
etdDbf6Tr4kt9+fy1/YL9yfqsCIIlz8SosaXJvqS+3d4uZPb5j+ukJmXub8EVONmvv8mzdIb
EG7g/thHz39M6i9bD2F/23Hqj1IfMmD+0sMT3Er8gWbd+OPu3zmpunb/Tr+52v0bX/qKN/En
rP7nJv++m/xvw3+n8HfSfvP8p2Pt/8ebgfcR/g8cFP5v4v9HzmH+b+HcTP+fIf8H2XZmlP/r
8yB2wP9lM/rR/n8QHef/EvMo/xc87uX/db5BNf+HD/r/EGdjTnec/0s/X6LB/j8G1Dji/0gX
P3WD/0u/TRzl/0V+Zzsb+/8JjrvR/r8T3Nn/38n/xV/j/yPv7+7c/5/83794jPov7i/mfwBQ
8f+Z/t+PnMP+f0s9Nuu/o1H9z4Pdkf9PFh0O67/AMP83yHj+56TLDW7qv+q4/ns3nP8Ry5P1
36E/U//zgv/I/wc/75lV/3nBTEb9B0e6U/9plP+b89V4VP+9wM78b6f+M/6i+n86/8NHqa0D
Z/2f9f/5Y+n/5ebnOKT/hzL/Qz/r/xOn1/8LmPkfxCUpt9P/S/rMtvO/HDK/0f87OuP/492S
wvHR//vY5/8CZlHL/v5vHOj/fUklMfX/OdJzoP8vt1zS/ysVR6Uf9v9Jz9LL/4uB0ir/5yha
y/+Zg8dr8v/qIa7J/4N8zf9N6Ipq+X+s5n958/I1CrPk/+kT2B8BxoSkImzl//RaG9+R/4vm
DfFW/s+vleFa/k8BXC3/R59HDZ38P/75Jv8n77cjQPTpQl7tDp8aAeZs3LH8X5H6G0/J/3Fn
/zdKFrnfIP+PUv5aQ/7vc+G5Qf6vZchryv/F5TycO+X/5ALr01PALNhr9f+hCQFOmFZr/b+g
p5+bAwb/Vf8f5iBwDgLn2TmG/o/p5uc45P+z6P9m/sczp8f/Ac39X4wcDPyP6nGL/zFHYfX4
n8oi59H8PyVp8//Uu83+b6qGtIP/FVUG+F+qzeDe/4fLS7b8f8oO8pX8v4TPvP87/j9F4bn6
/7hAUvv/SPROrvn/VA9xDf/7+N3/s2Dtj/+P1uu/pKnfGfj/MBD82ff/SZ2lkf+nblH4jfL/
otMXJq/9f17Zg63/T/DV+q9GTVC4w/9E/Oer/w+Kkf+XWie8KgH0EDcRfx/8D6lS3IH/AxUl
pu3/k/Wc1/F/hJKsaOb/RcAb/D+zasb/seG/T98iutn/x9NfyP+TFv0zQIP+4dWIf9B/EHX0
c/4/4av/D0/0P9H/PLvH0v/BX9T/OcGp/3vwHNb/yU7+nysaPyv/LwgP9H/oyO3l//lGj1fN
/+m9k2rl/7G4Jjewyf9b/k5r/o/kWt1Alf8jy8LmQ/l/4JY8vmPzf3Q+LvlG2/y/hELH+X/p
bm4w/2dZPgdj/p9exaIN2M7/8xbrYP/X52Xyc/l/y+v7BfP/hPrO6/9m/t+c///tY+r/bhYA
HNP/hen/8eA57v9RcnzN+u9H9T/r/xYdmKH/A8TKj6Op/yF9F8b6v8WPw9L/RWlxQ6P/izqs
/5mNHur/QqlzD+n/fOo5T+T/chQZ6v8xhPIZmfm/EEf5f+B0R/+/FDJT///OFLT0f4u+8bj+
r3yXfkH9T2i4KeJT/zfr/z91rPwPvfk5Ds3/Sv/PM//3mdPP/5bRlpH/J8b8jxd9Vjf/W1wb
mvkfnpn/carj2ur/mGmr/wtBd+Z/HktehzH/Iw+j+Z9w0QZa+r8yuruU/xdEHpj/kSyz2Cr/
L7T5Hz7nDNf6Pw9RL83/moe4qP/z8nX+l2PIqvw/rfV/7NV5e/4HQV++EHvzvzxF2+r/vJMq
OdDQ/wEBdfq/7GTbzf9AkVYLkJiukcib/D//df5H6qz8P47xav4foIznf0TunvwPKT7Fdv4f
EtyR/xeLjbOZ/5Hanf5eJ+Z/FGTj8/F+FQkeI8Ct878Y/kb+h3b5H+ra/L+SVvOe/1HCdD84
/5v5f3P+N8/VY/n/PY//wzr/42X/Z/J/j5wO/wtHO/87eiv/Ly7xDC3+5wT/Nvh/ieg4iP/1
lQ7c7P+U+Ora/08CKw/xfwSBwfoPubJcZPn/8bI0ZPn/kRX/4Y/4/2m+9t8B/z3ovgBQiNsF
oASXpTEAJMd1A5BALwS+JgCsH+KaAaAj/tYAgIO1AaCEOl7BdEsD4JDc6gDoVwdAzbBsH/6L
sq7/5OMAGFR30z/SU+pL7Fc5ALJ7bUbUDoAJkjbyv9SrSBv/51C/pn9ouoBWez5veJ76ZKpa
h3MOgBqG8X8Bot/sBp2C/8GP4789Ifj+xhMOgOi5l/h9/PkgxOvxf5KvSzb6JwlB+2TAS+A/
pEupPA7+NRtN1g6AqVetHQAF6tUfzdadP+cAyN8cAL0B8Cf2n9h/nu4Y+J/w5uc4sv+f/oiC
/2ni/yfOZv+nC/R77//kANst/ocFjW/wv27wP5c9nqP7P05jt//jQs//MyDLEP97fVFzZgMA
EEYNQIjsh/s/YBmAH2kAglMpM4vLDQB+3QDi2G0AlQ/t0wCoZHq02gBCytvqlzaAqoe4NgFw
oN8aAF+A9DIByF/VagJACYDh2gDo2gKkz0Bfqx97EwDTBBwwqt+bAHgSegVXVxMA516zhLoF
iBG1TgDnrHvuJgDuewvgxW0dAFJPnB7v6gaQE+hv+rQAqnyLA0DA4IYm4EwhbsYDx1sATV8L
+GO3AOmKgn06+IkJQAKJw/y/vDjP/XrQtQkAUPwLEwCipgkg0mYC4LXZ/wdy9IMTAPg6AaDZ
BcwuYJ6dY+p//2L+35L/Pfd/HjqH/T8Fx/rfZT/G8v/2Syadpf9VgpH+N2enjPW/qkP9L2nn
41nrf329b9Tpf8f7P5+doof0vyCL36it/y2fkeX/GZbXbuh/ISyaYtP/e0f/Gxdvd1P/G3m0
/5P1vzDU/2rx8T6s/138zX+H/ted3f+Z+t+p//3rx+D/lG9+ju/8n6v0v4X/o8n/PXI2/J9G
i//LXoWW/heD5f/jLP0v+lP6Xy3a3VX/i33+H2D2Cd/T/y7hhQf1v1RGz5b+Fy77fwKxc3fw
f1/1v73/p8OG/YMcsugb/a8Ehov63/UhrrF/oPEr+8dYsX8JSkI1/mdIlzT8+H+6yv8z3RK+
6X9jITR6/S+G12R8rP+NxQymYv8Afe//kyreS/n60f9G8hv973f2j5GrSf9H/xt9qGyBzul/
SX1/06r/ZbmH/RPWjcXPR/9LIjcIADL9FocCYHV3GACRahjRf5C+Mq6/8aIAWEXx7wuAuRUA
F73KRwCMoDwFwJP+m2eeeeaZZ5555plnnnnmmWeeef7q+X+lg4qKACADAA==
--------------050806060205040505050503--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
