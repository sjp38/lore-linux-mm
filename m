Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id D6ADC6B0068
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 15:35:23 -0400 (EDT)
Date: Mon, 2 Jul 2012 20:35:16 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [MMTests] IO metadata on XFS
Message-ID: <20120702193516.GX14154@suse.de>
References: <20120620113252.GE4011@suse.de>
 <20120629111932.GA14154@suse.de>
 <20120629112505.GF14154@suse.de>
 <20120701235458.GM19223@dastard>
 <20120702063226.GA32151@infradead.org>
 <20120702143215.GS14154@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120702143215.GS14154@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, dri-devel@lists.freedesktop.org, Keith Packard <keithp@keithp.com>, Eugeni Dodonov <eugeni.dodonov@intel.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, Chris Wilson <chris@chris-wilson.co.uk>

Adding dri-devel and a few others because an i915 patch contributed to
the regression.

On Mon, Jul 02, 2012 at 03:32:15PM +0100, Mel Gorman wrote:
> On Mon, Jul 02, 2012 at 02:32:26AM -0400, Christoph Hellwig wrote:
> > > It increases the CPU overhead (dirty_inode can be called up to 4
> > > times per write(2) call, IIRC), so with limited numbers of
> > > threads/limited CPU power it will result in lower performance. Where
> > > you have lots of CPU power, there will be little difference in
> > > performance...
> > 
> > When I checked it it could only be called twice, and we'd already
> > optimize away the second call.  I'd defintively like to track down where
> > the performance changes happend, at least to a major version but even
> > better to a -rc or git commit.
> > 
> 
> By all means feel free to run the test yourself and run the bisection :)
> 
> It's rare but on this occasion the test machine is idle so I started an
> automated git bisection. As you know the milage with an automated bisect
> varies so it may or may not find the right commit. Test machine is sandy so
> http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-metadata-xfs/sandy/comparison.html
> is the report of interest. The script is doing a full search between v3.3 and
> v3.4 for a point where average files/sec for fsmark-single drops below 25000.
> I did not limit the search to fs/xfs on the off-chance that it is an
> apparently unrelated patch that caused the problem.
> 

It was obvious very quickly that there were two distinct regression so I
ran two bisections. One led to a XFS and the other led to an i915 patch
that enables RC6 to reduce power usage.

[c999a223: xfs: introduce an allocation workqueue]
[aa464191: drm/i915: enable plain RC6 on Sandy Bridge by default]

gdm was running on the machine so i915 would have been in use.  In case it
is of interest this is the log of the bisection. Lines beginning with #
are notes I made and all other lines are from the bisection script. The
second-last column is the files/sec recorded by fsmark.

# MARK v3.3..v3.4 Search for BAD files/sec -lt 28000
# BAD 16536
# GOOD 34757
Mon Jul 2 15:46:13 IST 2012 sandy xfsbisect 141124c02059eee9dbc5c86ea797b1ca888e77f7 37454 good
Mon Jul 2 15:56:06 IST 2012 sandy xfsbisect 55a320308902f7a0746569ee57eeb3f254e6ed16 25192 bad
Mon Jul 2 16:08:34 IST 2012 sandy xfsbisect 281b05392fc2cb26209b4d85abaf4889ab1991f3 38807 good
Mon Jul 2 16:18:02 IST 2012 sandy xfsbisect a8364d5555b2030d093cde0f07951628e55454e1 37553 good
Mon Jul 2 16:27:22 IST 2012 sandy xfsbisect d2a2fc18d98d8ee2dec1542efc7f47beec256144 36676 good
Mon Jul 2 16:36:48 IST 2012 sandy xfsbisect 2e7580b0e75d771d93e24e681031a165b1d31071 37756 good
Mon Jul 2 16:46:36 IST 2012 sandy xfsbisect 532bfc851a7475fb6a36c1e953aa395798a7cca7 25416 bad
Mon Jul 2 16:56:10 IST 2012 sandy xfsbisect 0c9aac08261512d70d7d4817bd222abca8b6bdd6 38486 good
Mon Jul 2 17:05:40 IST 2012 sandy xfsbisect 0fc9d1040313047edf6a39fd4d7c7defdca97c62 37970 good
Mon Jul 2 17:16:01 IST 2012 sandy xfsbisect 5a5881cdeec2c019b5c9a307800218ee029f7f61 24493 bad
Mon Jul 2 17:21:15 IST 2012 sandy xfsbisect f616137519feb17b849894fcbe634a021d3fa7db 24405 bad
Mon Jul 2 17:26:16 IST 2012 sandy xfsbisect 5575acc7807595687288b3bbac15103f2a5462e1 37336 good
Mon Jul 2 17:31:25 IST 2012 sandy xfsbisect c999a223c2f0d31c64ef7379814cea1378b2b800 24552 bad
Mon Jul 2 17:36:34 IST 2012 sandy xfsbisect 1a1d772433d42aaff7315b3468fef5951604f5c6 36872 good
# c999a223c2f0d31c64ef7379814cea1378b2b800 is the first bad commit
# [c999a223: xfs: introduce an allocation workqueue]
#
# MARK c999a223c2f0d31c64ef7379814cea1378b2b800..v3.4 Search for BAD files/sec -lt 20000
# BAD  16536
# GOOD 24552
Mon Jul 2 17:48:39 IST 2012 sandy xfsbisect b2094ef840697bc8ca5d17a83b7e30fad5f1e9fa 37435 good
Mon Jul 2 17:58:12 IST 2012 sandy xfsbisect d2a2fc18d98d8ee2dec1542efc7f47beec256144 38303 good
Mon Jul 2 18:08:18 IST 2012 sandy xfsbisect 5d32c88f0b94061b3af2e3ade92422407282eb12 16718 bad
Mon Jul 2 18:18:02 IST 2012 sandy xfsbisect 2f7fa1be66dce77608330c5eb918d6360b5525f2 24964 good
Mon Jul 2 18:24:14 IST 2012 sandy xfsbisect 923f79743c76583ed4684e2c80c8da51a7268af3 24963 good
Mon Jul 2 18:33:49 IST 2012 sandy xfsbisect b61c37f57988567c84359645f8202a7c84bc798a 24824 good
Mon Jul 2 18:40:20 IST 2012 sandy xfsbisect 20a2a811602b16c42ce88bada3d52712cdfb988b 17155 bad
Mon Jul 2 18:50:12 IST 2012 sandy xfsbisect 78fb72f7936c01d5b426c03a691eca082b03f2b9 38494 good
Mon Jul 2 19:00:24 IST 2012 sandy xfsbisect e1a7eb08ee097e97e928062a242b0de5b2599a11 25033 good
Mon Jul 2 19:10:24 IST 2012 sandy xfsbisect 97effadb65ed08809e1720c8d3ee80b73a93665c 16520 bad
Mon Jul 2 19:16:16 IST 2012 sandy xfsbisect 25e341cfc33d94435472983825163e97fe370a6c 16748 bad
Mon Jul 2 19:21:52 IST 2012 sandy xfsbisect 7dd4906586274f3945f2aeaaa5a33b451c3b4bba 24957 good
Mon Jul 2 19:27:35 IST 2012 sandy xfsbisect aa46419186992e6b8b8010319f0ca7f40a0d13f5 17088 bad
Mon Jul 2 19:32:54 IST 2012 sandy xfsbisect 83b7f9ac9126f0532ca34c14e4f0582c565c6b0d 25667 good
# aa46419186992e6b8b8010319f0ca7f40a0d13f5 is the first bad commit
# [aa464191: drm/i915: enable plain RC6 on Sandy Bridge by default]

I tested plain reverts of the patches individually and together and got
the following results 

FS-Mark Single Threaded
                                        3.4.0                3.4.0                 3.4.0
                 3.4.0-vanilla          revert-aa464191      revert-c999a223       revert-both
Files/s  min       14176.40 ( 0.00%)    17830.60 (25.78%)    24186.70 (70.61%)    25108.00 (77.11%)
Files/s  mean      16783.35 ( 0.00%)    25029.69 (49.13%)    37513.72 (123.52%)   38169.97 (127.43%)
Files/s  stddev     1007.26 ( 0.00%)     2644.87 (162.58%)     5344.99 (430.65%)   5599.65 (455.93%)
Files/s  max       18475.40 ( 0.00%)    27966.10 (51.37%)    45564.60 (146.62%)   47918.10 (159.36%)
Overhead min      593978.00 ( 0.00%)   386173.00 (34.99%)   253812.00 (57.27%)   247396.00 (58.35%)
Overhead mean     637782.80 ( 0.00%)   429229.33 (32.70%)   322868.20 (49.38%)   287141.73 (54.98%)
Overhead stddev    72440.72 ( 0.00%)   100056.96 (-38.12%)   175001.08 (-141.58%)   102018.14 (-40.83%)
Overhead max      855637.00 ( 0.00%)   753541.00 (11.93%)   880531.00 (-2.91%)   637932.00 (25.44%)
MMTests Statistics: duration
Sys Time Running Test (seconds)              44.06     32.25     24.19     23.99
User+Sys Time Running Test (seconds)         50.19     36.35     27.24      26.7
Total Elapsed Time (seconds)                 59.21     44.76     34.95     34.14

Individually reverting either patch makes a difference to both files/sec
and overhead. Reverting both is not as dramatic as reverting each individual
patch would indicate but it's still a major improvement.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
