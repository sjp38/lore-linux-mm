Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1FBEB600309
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 05:56:36 -0500 (EST)
Date: Mon, 30 Nov 2009 12:56:12 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v2 10/12] Maintain preemptability count even for
 !CONFIG_PREEMPT kernels
Message-ID: <20091130105612.GF30150@redhat.com>
References: <1258985167-29178-1-git-send-email-gleb@redhat.com>
 <1258985167-29178-11-git-send-email-gleb@redhat.com>
 <1258990455.4531.594.camel@laptop>
 <20091123155851.GU2999@redhat.com>
 <alpine.DEB.2.00.0911231128190.785@router.home>
 <20091124071250.GC2999@redhat.com>
 <alpine.DEB.2.00.0911240906360.14045@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0911240906360.14045@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, Nov 24, 2009 at 09:14:03AM -0600, Christoph Lameter wrote:
> On Tue, 24 Nov 2009, Gleb Natapov wrote:
> 
> > On Mon, Nov 23, 2009 at 11:30:02AM -0600, Christoph Lameter wrote:
> > > This adds significant overhead for the !PREEMPT case adding lots of code
> > > in critical paths all over the place.
> > I want to measure it. Can you suggest benchmarks to try?
> 
> AIM9 (reaim9)?
Below are results for kernel 2.6.32-rc8 with and without the patch (only
this single patch is applied).

test name           with (stddev)            without (stddev)
===========================================================================
jmp_test         57853.762 ( 1086.51)  55664.287 ( 5152.14)    3.93%
stream_pipe      10286.967 (  132.01)  11396.327 (  306.01)   -9.73%
new_raph         12573.395 (    2.64)  12535.764 (   85.14)    0.30%
sync_disk_rw         0.100 (    0.00)      0.100 (    0.00)   -0.44%
udp_test          4008.058 (   37.57)   3774.514 (   22.03)    6.19%
add_long            68.542 (    0.00)     68.530 (    0.01)    0.02%
exec_test          181.615 (    0.46)    184.503 (    0.42)   -1.57%
div_double         114.209 (    0.02)    114.230 (    0.03)   -0.02%
mem_rtns_1         283.733 (    3.27)    285.936 (    2.24)   -0.77%
sync_disk_cp         0.043 (    0.00)      0.043 (    0.00)    0.03%
fun_cal2           780.701 (    0.16)    780.867 (    0.07)   -0.02%
matrix_rtns      70160.568 (   28.58)  70181.900 (   16.46)   -0.03%
fun_cal1           780.701 (    0.16)    780.763 (    0.13)   -0.01%
div_int            219.216 (    0.03)    219.264 (    0.04)   -0.02%
pipe_cpy         16239.120 (  468.99)  16727.067 (  280.27)   -2.92%
fifo_test        12864.276 (  242.82)  13383.616 (  199.31)   -3.88%
sync_disk_wrt        0.043 (    0.00)      0.043 (    0.00)   -0.11%
mul_long          4276.703 (    0.79)   4277.528 (    0.65)   -0.02%
num_rtns_1        4308.165 (    5.99)   4306.133 (    5.84)    0.05%
disk_src          1507.993 (    8.04)   1586.100 (    5.44)   -4.92%
mul_short         3422.840 (    0.31)   3423.280 (    0.24)   -0.01%
series_1        121706.708 (  266.62) 121356.355 (  982.04)    0.29%
mul_int           4277.353 (    0.45)   4277.953 (    0.34)   -0.01%
mul_float           99.947 (    0.02)     99.947 (    0.02)   -0.00%
link_test         2319.090 (   12.51)   2466.564 (    1.52)   -5.98%
fun_cal15          380.836 (    0.06)    380.876 (    0.10)   -0.01%
trig_rtns          163.416 (    0.13)    163.185 (    0.51)    0.14%
fun_cal            915.226 (    4.56)    902.033 (    1.44)    1.46%
misc_rtns_1       4285.322 (   18.72)   4282.907 (   27.07)    0.06%
brk_test           221.167 (    8.98)    230.345 (    7.98)   -3.98%
add_float          133.242 (    0.02)    133.249 (    0.02)   -0.01%
page_test          284.488 (    3.71)    284.180 (   13.91)    0.11%
div_long            85.364 (    0.27)     85.222 (    0.02)    0.17%
dir_rtns_1         207.953 (    2.56)    212.532 (    0.59)   -2.15%
disk_cp             66.449 (    0.43)     65.754 (    0.61)    1.06%
sieve               23.538 (    0.01)     23.599 (    0.11)   -0.26%
tcp_test          2085.428 (   18.43)   2059.062 (    5.52)    1.28%
disk_wrt            81.839 (    0.16)     82.652 (    0.41)   -0.98%
mul_double          79.951 (    0.01)     79.961 (    0.02)   -0.01%
fork_test           57.408 (    0.43)     57.835 (    0.27)   -0.74%
add_short          171.326 (    0.03)    171.314 (    0.01)    0.01%
creat-clo          395.995 (    3.63)    403.918 (    2.74)   -1.96%
sort_rtns_1        276.833 (   31.80)    290.855 (    0.46)   -4.82%
add_int             79.961 (    0.02)     79.967 (    0.00)   -0.01%
disk_rr             67.635 (    0.23)     68.282 (    0.59)   -0.95%
div_short          210.318 (    0.04)    210.365 (    0.05)   -0.02%
disk_rw             57.041 (    0.26)     57.470 (    0.31)   -0.75%
dgram_pipe       10088.191 (   86.81)   9848.119 (  406.33)    2.44%
shell_rtns_3       681.882 (    3.30)    693.734 (    2.67)   -1.71%
shell_rtns_2       681.721 (    3.24)    693.307 (    2.90)   -1.67%
shell_rtns_1       681.116 (    3.46)    692.302 (    3.16)   -1.62%
div_float          114.224 (    0.02)    114.230 (    0.00)   -0.01%
ram_copy        217812.436 (  615.62) 218160.548 (  135.66)   -0.16%
shared_memory    11022.611 (   20.75)  10870.031 (   61.44)    1.40%
signal_test        700.907 (    1.42)    711.253 (    0.49)   -1.46%
add_double          88.836 (    0.00)     88.837 (    0.00)   -0.00%
array_rtns         119.369 (    0.06)    119.182 (    0.36)    0.16%
string_rtns         97.107 (    0.21)     97.160 (    0.22)   -0.05%
disk_rd            626.890 (   18.25)    586.034 (    5.58)    6.97%

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
