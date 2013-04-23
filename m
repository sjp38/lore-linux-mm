Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 88E1D6B0002
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 11:33:09 -0400 (EDT)
Date: Tue, 23 Apr 2013 16:33:05 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130423153305.GB2108@suse.de>
References: <20130402142717.GH32241@suse.de>
 <20130402150651.GB31577@thunk.org>
 <20130410105608.GC1910@suse.de>
 <20130410131245.GC4862@thunk.org>
 <20130411170402.GB11656@suse.de>
 <20130411183512.GA12298@thunk.org>
 <20130411213335.GE9379@quack.suse.cz>
 <20130412025708.GB7445@thunk.org>
 <20130412094731.GI11656@suse.de>
 <20130421000522.GA5054@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130421000522.GA5054@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

On Sat, Apr 20, 2013 at 08:05:22PM -0400, Theodore Ts'o wrote:
> An alternate solution which I've been playing around adds buffer_head
> flags so we can indicate that a buffer contains metadata and/or should
> have I/O submitted with the REQ_PRIO flag set.
> 

I beefed up the reporting slightly and tested the patches comparing
3.9-rc6 vanilla with your patches. The full report with graphs are at

http://www.csn.ul.ie/~mel/postings/ext4tag-20130423/report.html

                           3.9.0-rc6             3.9.0-rc6
                             vanilla               ext4tag
User    min           0.00 (  0.00%)        0.00 (  0.00%)
User    mean           nan (   nan%)         nan (   nan%)
User    stddev         nan (   nan%)         nan (   nan%)
User    max           0.00 (  0.00%)        0.00 (  0.00%)
User    range         0.00 (  0.00%)        0.00 (  0.00%)
System  min           9.14 (  0.00%)        9.13 (  0.11%)
System  mean          9.60 (  0.00%)        9.73 ( -1.33%)
System  stddev        0.39 (  0.00%)        0.94 (-142.69%)
System  max          10.31 (  0.00%)       11.58 (-12.32%)
System  range         1.17 (  0.00%)        2.45 (-109.40%)
Elapsed min         665.54 (  0.00%)      612.25 (  8.01%)
Elapsed mean        775.35 (  0.00%)      688.01 ( 11.26%)
Elapsed stddev       69.11 (  0.00%)       58.22 ( 15.75%)
Elapsed max         858.40 (  0.00%)      773.06 (  9.94%)
Elapsed range       192.86 (  0.00%)      160.81 ( 16.62%)
CPU     min           3.00 (  0.00%)        3.00 (  0.00%)
CPU     mean          3.60 (  0.00%)        4.20 (-16.67%)
CPU     stddev        0.49 (  0.00%)        0.75 (-52.75%)
CPU     max           4.00 (  0.00%)        5.00 (-25.00%)
CPU     range         1.00 (  0.00%)        2.00 (-100.00%)

The patches appear to improve the git checkout times slightly but this
test is quite variable.

The vmstat figures report some reclaim activity but if you look at the graphs
further down you will see that the bulk of the kswapd reclaim scan and
steal activity is at the start of the test when it's downloading and
untarring a git tree to work with. (I also note that the mouse-over
graph for direct reclaim efficiency is broken but it's not important
right now).

>From iostat

                    3.9.0-rc6   3.9.0-rc6
                      vanilla     ext4tag
Mean dm-0-avgqz          1.18        1.19
Mean dm-0-await         17.30       16.50
Mean dm-0-r_await       17.30       16.50
Mean dm-0-w_await        0.94        0.48
Mean sda-avgqz         650.29      719.81
Mean sda-await        2501.33     2597.23
Mean sda-r_await        30.01       24.91
Mean sda-w_await     11228.80    11120.64
Max  dm-0-avgqz         12.30       10.14
Max  dm-0-await         42.65       52.23
Max  dm-0-r_await       42.65       52.23
Max  dm-0-w_await      541.00      263.83
Max  sda-avgqz        3811.93     3375.11
Max  sda-await        7178.61     7170.44
Max  sda-r_await       384.37      297.85
Max  sda-w_await     51353.93    50338.25

There are no really obvious massive advantages to me there and if you look
at the graphs for the avgqs, await etc over time, the patched kernel are
not obviously better. The Wait CPU usage looks roughly the same too.

On the more positive side, the dstate systemtap monitor script tells me
that all processes were stalled for less time -- 9575 seconds versus
10910. The most severe event to stall on is sleep_on_buffer() as a
result of ext4_bread.

Vanilla kernel	3325677 ms stalled with 57 events
Patched kernel  2411471 ms stalled with 42 events

That's a pretty big drop but it gets bad again for the second worst stall --
wait_on_page_bit as a result of generic_file_buffered_write.

Vanilla kernel  1336064 ms stalled with 109 events
Patched kernel  2338781 ms stalled with 164 events

So conceptually the patches make sense but the first set of tests do
not indicate that they'll fix the problem and the stall times do not
indicate that interactivity will be any better. I'll still apply them
and boot them on my main work machine and see how they "feel" this
evening.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
