Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8A0926B002C
	for <linux-mm@kvack.org>; Sun, 16 Oct 2011 23:03:21 -0400 (EDT)
Date: Mon, 17 Oct 2011 11:03:10 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/11] IO-less dirty throttling v12
Message-ID: <20111017030310.GA30011@localhost>
References: <20111003134228.090592370@intel.com>
 <1318248846.14400.21.camel@laptop>
 <20111010130722.GA11387@localhost>
 <20111010142846.GA21218@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="r5Pyd7+fXNt84Ff3"
Content-Disposition: inline
In-Reply-To: <20111010142846.GA21218@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Trond,

I enhanced the script to compare the write_bw as well as the NFS
write/commit stats.

      3.1.0-rc4-vanilla+         3.1.0-rc8-nfs-wq+
------------------------  ------------------------
(MB/s)            275.28       +28.5%       353.72  TOTAL write_bw

                 5649.00      +192.3%     16510.00  TOTAL nfs_nr_commits (*)
               261987.00      +205.1%    799451.00  TOTAL nfs_nr_writes  (*)

(MB)              866.52       -18.1%       709.85  TOTAL nfs_commit_size (**)
                    2.94       -44.8%         1.62  TOTAL nfs_write_size

(ms)            47814.05       -84.0%      7631.57  TOTAL nfs_write_queue_time
                 1405.05       -53.6%       652.59  TOTAL nfs_write_rtt_time
                49237.94       -83.2%      8292.74  TOTAL nfs_write_execute_time

                 4320.98       -83.2%       726.27  TOTAL nfs_commit_queue_time
                22943.13        -8.6%     20963.46  TOTAL nfs_commit_rtt_time
                27307.42       -20.5%     21714.12  TOTAL nfs_commit_execute_time

(*) The x3 nfs_nr_writes and nfs_nr_commits numbers should be taken
    with a salt because the total written bytes are increased at the
    same time.

(**) The TOTAL nfs_commit_size mainly reflects the thresh=1G cases
     because the numbers in the 10M/100M cases are very small
     comparing to the 1G cases (as shown in the below case by case
     values). Ditto for the *_time values.  However the thresh=1G
     cases should be most close to the typical NFS client setup, so
     the values are still mostly representative numbers.

Below are the detailed case by case views. The script is attached,
which shows how exactly the numbers are calculated from mountstats.

Thanks,
Fengguang
---

      3.1.0-rc4-vanilla+         3.1.0-rc8-nfs-wq+
------------------------  ------------------------
                   20.89       +95.2%        40.77  NFS-thresh=100M/nfs-10dd-1M-32p-32768M-100M:10-X
                   39.43        +9.2%        43.07  NFS-thresh=100M/nfs-1dd-1M-32p-32768M-100M:10-X
                   26.60       +70.6%        45.39  NFS-thresh=100M/nfs-2dd-1M-32p-32768M-100M:10-X
                   12.70       +56.1%        19.83  NFS-thresh=10M/nfs-10dd-1M-32p-32768M-10M:10-X
                   27.41       +19.7%        32.81  NFS-thresh=10M/nfs-1dd-1M-32p-32768M-10M:10-X
                   26.52       +16.8%        30.97  NFS-thresh=10M/nfs-2dd-1M-32p-32768M-10M:10-X
                   40.70       +16.5%        47.42  NFS-thresh=1G/nfs-10dd-1M-32p-32768M-1024M:10-X
                   45.28        -2.4%        44.20  NFS-thresh=1G/nfs-1dd-1M-32p-32768M-1024M:10-X
                   35.74       +37.8%        49.26  NFS-thresh=1G/nfs-2dd-1M-32p-32768M-1024M:10-X
                  275.28       +28.5%       353.72  TOTAL write_bw

      3.1.0-rc4-vanilla+         3.1.0-rc8-nfs-wq+
------------------------  ------------------------
                  825.00      +196.8%      2449.00  NFS-thresh=100M/nfs-10dd-1M-32p-32768M-100M:10-X
                  250.00        +6.8%       267.00  NFS-thresh=100M/nfs-1dd-1M-32p-32768M-100M:10-X
                  272.00      +114.7%       584.00  NFS-thresh=100M/nfs-2dd-1M-32p-32768M-100M:10-X
                 1477.00      +350.8%      6658.00  NFS-thresh=10M/nfs-10dd-1M-32p-32768M-10M:10-X
                  997.00      +115.8%      2152.00  NFS-thresh=10M/nfs-1dd-1M-32p-32768M-10M:10-X
                 1521.00      +154.3%      3868.00  NFS-thresh=10M/nfs-2dd-1M-32p-32768M-10M:10-X
                  235.00       +83.4%       431.00  NFS-thresh=1G/nfs-10dd-1M-32p-32768M-1024M:10-X
                   29.00       +20.7%        35.00  NFS-thresh=1G/nfs-1dd-1M-32p-32768M-1024M:10-X
                   43.00       +53.5%        66.00  NFS-thresh=1G/nfs-2dd-1M-32p-32768M-1024M:10-X
                 5649.00      +192.3%     16510.00  TOTAL nfs_nr_commits

      3.1.0-rc4-vanilla+         3.1.0-rc8-nfs-wq+
------------------------  ------------------------
                32294.00       -14.6%     27571.00  NFS-thresh=100M/nfs-10dd-1M-32p-32768M-100M:10-X
                28858.00      +616.0%    206620.00  NFS-thresh=100M/nfs-1dd-1M-32p-32768M-100M:10-X
                32593.00      +202.7%     98662.00  NFS-thresh=100M/nfs-2dd-1M-32p-32768M-100M:10-X
                18937.00      +111.7%     40085.00  NFS-thresh=10M/nfs-10dd-1M-32p-32768M-10M:10-X
                18762.00      +660.5%    142691.00  NFS-thresh=10M/nfs-1dd-1M-32p-32768M-10M:10-X
                21473.00      +298.8%     85640.00  NFS-thresh=10M/nfs-2dd-1M-32p-32768M-10M:10-X
                47281.00        +5.0%     49625.00  NFS-thresh=1G/nfs-10dd-1M-32p-32768M-1024M:10-X
                33108.00       +77.1%     58632.00  NFS-thresh=1G/nfs-1dd-1M-32p-32768M-1024M:10-X
                28681.00      +213.5%     89925.00  NFS-thresh=1G/nfs-2dd-1M-32p-32768M-1024M:10-X
               261987.00      +205.1%    799451.00  TOTAL nfs_nr_writes

      3.1.0-rc4-vanilla+         3.1.0-rc8-nfs-wq+
------------------------  ------------------------
                    7.69       -35.6%         4.95  NFS-thresh=100M/nfs-10dd-1M-32p-32768M-100M:10-X
                   47.41        -1.3%        46.81  NFS-thresh=100M/nfs-1dd-1M-32p-32768M-100M:10-X
                   29.39       -22.1%        22.90  NFS-thresh=100M/nfs-2dd-1M-32p-32768M-100M:10-X
                    2.73       -68.3%         0.87  NFS-thresh=10M/nfs-10dd-1M-32p-32768M-10M:10-X
                    8.24       -46.7%         4.39  NFS-thresh=10M/nfs-1dd-1M-32p-32768M-10M:10-X
                    5.21       -55.1%         2.34  NFS-thresh=10M/nfs-2dd-1M-32p-32768M-10M:10-X
                   56.99       -42.5%        32.79  NFS-thresh=1G/nfs-10dd-1M-32p-32768M-1024M:10-X
                  453.65       -18.1%       371.54  NFS-thresh=1G/nfs-1dd-1M-32p-32768M-1024M:10-X
                  255.21       -12.5%       223.26  NFS-thresh=1G/nfs-2dd-1M-32p-32768M-1024M:10-X
                  866.52       -18.1%       709.85  TOTAL nfs_commit_size

      3.1.0-rc4-vanilla+         3.1.0-rc8-nfs-wq+
------------------------  ------------------------
                    0.20      +123.8%         0.44  NFS-thresh=100M/nfs-10dd-1M-32p-32768M-100M:10-X
                    0.41       -85.3%         0.06  NFS-thresh=100M/nfs-1dd-1M-32p-32768M-100M:10-X
                    0.25       -44.7%         0.14  NFS-thresh=100M/nfs-2dd-1M-32p-32768M-100M:10-X
                    0.21       -32.4%         0.14  NFS-thresh=10M/nfs-10dd-1M-32p-32768M-10M:10-X
                    0.44       -84.9%         0.07  NFS-thresh=10M/nfs-1dd-1M-32p-32768M-10M:10-X
                    0.37       -71.4%         0.11  NFS-thresh=10M/nfs-2dd-1M-32p-32768M-10M:10-X
                    0.28        +0.5%         0.28  NFS-thresh=1G/nfs-10dd-1M-32p-32768M-1024M:10-X
                    0.40       -44.2%         0.22  NFS-thresh=1G/nfs-1dd-1M-32p-32768M-1024M:10-X
                    0.38       -57.2%         0.16  NFS-thresh=1G/nfs-2dd-1M-32p-32768M-1024M:10-X
                    2.94       -44.8%         1.62  TOTAL nfs_write_size

      3.1.0-rc4-vanilla+         3.1.0-rc8-nfs-wq+
------------------------  ------------------------
                 3249.09       -93.2%       222.32  NFS-thresh=100M/nfs-10dd-1M-32p-32768M-100M:10-X
                  221.23       +98.2%       438.48  NFS-thresh=100M/nfs-1dd-1M-32p-32768M-100M:10-X
                 5942.01       -68.7%      1857.66  NFS-thresh=100M/nfs-2dd-1M-32p-32768M-100M:10-X
                  285.75       -99.9%         0.38  NFS-thresh=10M/nfs-10dd-1M-32p-32768M-10M:10-X
                    6.21       -95.4%         0.28  NFS-thresh=10M/nfs-1dd-1M-32p-32768M-10M:10-X
                   34.73       -92.4%         2.63  NFS-thresh=10M/nfs-2dd-1M-32p-32768M-10M:10-X
                29155.55       -99.3%       215.70  NFS-thresh=1G/nfs-10dd-1M-32p-32768M-1024M:10-X
                 2704.81        -6.3%      2535.52  NFS-thresh=1G/nfs-1dd-1M-32p-32768M-1024M:10-X
                 6214.66       -62.0%      2358.60  NFS-thresh=1G/nfs-2dd-1M-32p-32768M-1024M:10-X
                47814.05       -84.0%      7631.57  TOTAL nfs_write_queue_time

      3.1.0-rc4-vanilla+         3.1.0-rc8-nfs-wq+
------------------------  ------------------------
                  268.37       -69.6%        81.55  NFS-thresh=100M/nfs-10dd-1M-32p-32768M-100M:10-X
                   80.00       -38.0%        49.59  NFS-thresh=100M/nfs-1dd-1M-32p-32768M-100M:10-X
                  110.81       -50.8%        54.54  NFS-thresh=100M/nfs-2dd-1M-32p-32768M-100M:10-X
                  295.72       -41.7%       172.52  NFS-thresh=10M/nfs-10dd-1M-32p-32768M-10M:10-X
                   36.64       -31.6%        25.05  NFS-thresh=10M/nfs-1dd-1M-32p-32768M-10M:10-X
                  100.70       -33.5%        66.93  NFS-thresh=10M/nfs-2dd-1M-32p-32768M-10M:10-X
                  253.68       -67.2%        83.33  NFS-thresh=1G/nfs-10dd-1M-32p-32768M-1024M:10-X
                   55.16       +46.4%        80.77  NFS-thresh=1G/nfs-1dd-1M-32p-32768M-1024M:10-X
                  203.96       -81.2%        38.30  NFS-thresh=1G/nfs-2dd-1M-32p-32768M-1024M:10-X
                 1405.05       -53.6%       652.59  TOTAL nfs_write_rtt_time

      3.1.0-rc4-vanilla+         3.1.0-rc8-nfs-wq+
------------------------  ------------------------
                 3517.58       -91.4%       304.13  NFS-thresh=100M/nfs-10dd-1M-32p-32768M-100M:10-X
                  302.26       +61.7%       488.90  NFS-thresh=100M/nfs-1dd-1M-32p-32768M-100M:10-X
                 6053.53       -68.4%      1912.75  NFS-thresh=100M/nfs-2dd-1M-32p-32768M-100M:10-X
                  581.52       -70.3%       173.00  NFS-thresh=10M/nfs-10dd-1M-32p-32768M-10M:10-X
                   42.99       -40.7%        25.47  NFS-thresh=10M/nfs-1dd-1M-32p-32768M-10M:10-X
                  135.56       -48.5%        69.75  NFS-thresh=10M/nfs-2dd-1M-32p-32768M-10M:10-X
                29411.03       -99.0%       299.78  NFS-thresh=1G/nfs-10dd-1M-32p-32768M-1024M:10-X
                 2768.01        -5.4%      2618.62  NFS-thresh=1G/nfs-1dd-1M-32p-32768M-1024M:10-X
                 6425.46       -62.6%      2400.33  NFS-thresh=1G/nfs-2dd-1M-32p-32768M-1024M:10-X
                49237.94       -83.2%      8292.74  TOTAL nfs_write_execute_time

      3.1.0-rc4-vanilla+         3.1.0-rc8-nfs-wq+
------------------------  ------------------------
                   99.56       -97.5%         2.49  NFS-thresh=100M/nfs-10dd-1M-32p-32768M-100M:10-X
                  108.12       -83.8%        17.50  NFS-thresh=100M/nfs-1dd-1M-32p-32768M-100M:10-X
                   89.87       -97.5%         2.26  NFS-thresh=100M/nfs-2dd-1M-32p-32768M-100M:10-X
                    9.00       -90.5%         0.85  NFS-thresh=10M/nfs-10dd-1M-32p-32768M-10M:10-X
                    2.41       -58.2%         1.01  NFS-thresh=10M/nfs-1dd-1M-32p-32768M-10M:10-X
                    2.68       -59.9%         1.07  NFS-thresh=10M/nfs-2dd-1M-32p-32768M-10M:10-X
                 1398.01       -64.0%       503.61  NFS-thresh=1G/nfs-10dd-1M-32p-32768M-1024M:10-X
                 1558.97       -97.9%        33.03  NFS-thresh=1G/nfs-1dd-1M-32p-32768M-1024M:10-X
                 1052.37       -84.4%       164.45  NFS-thresh=1G/nfs-2dd-1M-32p-32768M-1024M:10-X
                 4320.98       -83.2%       726.27  TOTAL nfs_commit_queue_time

      3.1.0-rc4-vanilla+         3.1.0-rc8-nfs-wq+
------------------------  ------------------------
                  896.68        -6.3%       840.25  NFS-thresh=100M/nfs-10dd-1M-32p-32768M-100M:10-X
                  919.00        +0.9%       926.98  NFS-thresh=100M/nfs-1dd-1M-32p-32768M-100M:10-X
                 1088.05       -24.0%       827.14  NFS-thresh=100M/nfs-2dd-1M-32p-32768M-100M:10-X
                  266.54       -22.7%       206.09  NFS-thresh=10M/nfs-10dd-1M-32p-32768M-10M:10-X
                  191.28       -41.3%       112.32  NFS-thresh=10M/nfs-1dd-1M-32p-32768M-10M:10-X
                  187.90       -34.0%       123.98  NFS-thresh=10M/nfs-2dd-1M-32p-32768M-10M:10-X
                 4671.46       -11.8%      4119.49  NFS-thresh=1G/nfs-10dd-1M-32p-32768M-1024M:10-X
                 6586.97        -3.1%      6382.66  NFS-thresh=1G/nfs-1dd-1M-32p-32768M-1024M:10-X
                 8135.26        -8.7%      7424.56  NFS-thresh=1G/nfs-2dd-1M-32p-32768M-1024M:10-X
                22943.13        -8.6%     20963.46  TOTAL nfs_commit_rtt_time

      3.1.0-rc4-vanilla+         3.1.0-rc8-nfs-wq+
------------------------  ------------------------
                  996.58       -15.4%       843.02  NFS-thresh=100M/nfs-10dd-1M-32p-32768M-100M:10-X
                 1027.14        -8.0%       944.51  NFS-thresh=100M/nfs-1dd-1M-32p-32768M-100M:10-X
                 1178.59       -29.6%       829.52  NFS-thresh=100M/nfs-2dd-1M-32p-32768M-100M:10-X
                  275.75       -24.9%       207.03  NFS-thresh=10M/nfs-10dd-1M-32p-32768M-10M:10-X
                  193.71       -41.5%       113.35  NFS-thresh=10M/nfs-1dd-1M-32p-32768M-10M:10-X
                  190.67       -34.4%       125.12  NFS-thresh=10M/nfs-2dd-1M-32p-32768M-10M:10-X
                 6071.22       -23.8%      4624.14  NFS-thresh=1G/nfs-10dd-1M-32p-32768M-1024M:10-X
                 8146.03       -21.2%      6415.71  NFS-thresh=1G/nfs-1dd-1M-32p-32768M-1024M:10-X
                 9227.72       -17.5%      7611.71  NFS-thresh=1G/nfs-2dd-1M-32p-32768M-1024M:10-X
                27307.42       -20.5%     21714.12  TOTAL nfs_commit_execute_time


--r5Pyd7+fXNt84Ff3
Content-Type: application/x-ruby
Content-Disposition: attachment; filename="compare.rb"
Content-Transfer-Encoding: quoted-printable

#!/usr/bin/ruby=0A=0Arequire 'optparse'=0Arequire 'ostruct'=0A=0ANFS_MNT=3D=
"/fs/nfs"=0A=0A$cfield =3D "kernel"=0A$cfield_hash =3D Hash.new=0A$cfield_a=
rray =3D Array.new=0A$cases =3D Hash.new=0A$sum =3D Array.new=0A$grep =3D /=
/=0A=0A$cvalue =3D "write_bw"=0A=0A$nfs_nr_commits =3D 0=0A$nfs_nr_writes =
=3D 0=0A=0A$nfs_write_total =3D 0=0A$nfs_commit_size =3D 0=0A$nfs_write_siz=
e =3D 0=0A=0A$nfs_write_queue_time =3D 0=0A$nfs_write_rtt_time =3D 0=0A$nfs=
_write_execute_time =3D 0=0A=0A$nfs_commit_queue_time =3D 0=0A$nfs_commit_r=
tt_time =3D 0=0A$nfs_commit_execute_time =3D 0=0A=0Aopts =3D OptionParser.n=
ew do |opts|=0A        opts.banner =3D "Usage: compare.rb [options] cases..=
=2E"=0A=0A        opts.separator ""=0A        opts.separator "options:"=0A=
=0A        opts.on("-c FIELD", "--compare FIELD", "compare FIELD: fs/kernel=
/nr/thresh/bg_thresh") do |field|=0A                $cfield =3D field=0A		#=
 puts "#{$cfield}\n"=0A        end=0A       =0A        opts.on("-v FIELD", =
"--value FIELD", "evalute FIELD: write_bw/nfs_*") do |field|=0A            =
    $cvalue =3D field=0A        end=0A       =0A        opts.on("-g PATTERN=
", "--grep PATTERN", "only compare cases that match PATTERN") do |pattern|=
=0A                $grep =3D Regexp.new(pattern)=0A        end=0A       =0A=
        opts.on_tail("-h", "--help", "Show this message") do=0A            =
    puts opts=0A                exit=0A        end=0A=0Aend=0A=0Aopts.parse=
!(ARGV)=0A=0A# http://bits.stephan-brumme.com/roundUpToNextPowerOfTwo.html=
=0Adef roundUpToNextPowerOfTwo(x)=0A	x -=3D 1=0A	x |=3D x >> 1;  # handle  =
2 bit numbers=0A	x |=3D x >> 2;  # handle  4 bit numbers=0A	x |=3D x >> 4; =
 # handle  8 bit numbers=0A	x |=3D x >> 8;  # handle 16 bit numbers=0A	x |=
=3D x >> 16; # handle 32 bit numbers=0A	x +=3D 1=0A	return x;=0Aend=0A=0Ade=
f written_pages(path)=0A	written =3D 0=0A	if File.exist?("#{path}/vmstat-en=
d")=0A		vmstat =3D File.new("#{path}/vmstat-end").readlines=0A		vmstat.grep=
(/nr_written (\d+)/) { written =3D $1.to_i }=0A	end=0A	return written=0A	# =
File.open("#{path}/vmstat-end").each_line do |line|=0A	# 	if line =3D~ /nr_=
written (\d+)/=0A	# 		written =3D $1.to_i=0A	# 		break=0A	# 	end=0A	# end=
=0Aend=0A=0Adef nfs_stats(path)=0A	file =3D "#{path}/mountstats-end"=0A=0A	=
$nfs_nr_commits =3D 0=0A	$nfs_nr_writes =3D 0=0A=0A	$nfs_write_mb =3D 0=0A	=
$nfs_nr_commits_per_mb =3D 0=0A	$nfs_nr_writes_per_mb =3D 0=0A=0A	$nfs_writ=
e_queue_time =3D 0=0A	$nfs_write_rtt_time =3D 0=0A	$nfs_write_execute_time =
=3D 0=0A=0A	$nfs_commit_queue_time =3D 0=0A	$nfs_commit_rtt_time =3D 0=0A	$=
nfs_commit_execute_time =3D 0=0A=0A	return if not File.exist?(file)=0A	=0A	=
stat =3D File.new(file).readlines=0A	nfsmnt =3D nil=0A	stat.each do |line|=
=0A		if line.index("mounted on /")=0A			nfsmnt =3D line.index("mounted on #=
{NFS_MNT}")=0A		end=0A		next unless nfsmnt=0A		if line.index("WRITE: ")=0A	=
		n =3D line.split=0A			$nfs_nr_writes =3D n[1].to_i=0A			next if $nfs_nr_w=
rites =3D=3D 0=0A			$nfs_write_total =3D n[4].to_f=0A			$nfs_write_size =3D=
 $nfs_write_total / $nfs_nr_writes / (1<<20)=0A			$nfs_write_queue_time   =
=3D n[6].to_f / $nfs_nr_writes=0A			$nfs_write_rtt_time     =3D n[7].to_f /=
 $nfs_nr_writes=0A			$nfs_write_execute_time =3D n[8].to_f / $nfs_nr_writes=
=0A			# puts line=0A			# puts $nfs_nr_writes=0A		end=0A		if line.index("COM=
MIT: ")=0A			n =3D line.split=0A			$nfs_nr_commits =3D n[1].to_i=0A			next =
if $nfs_nr_commits =3D=3D 0=0A			$nfs_commit_size =3D $nfs_write_total / $n=
fs_nr_commits / (1<<20)=0A			$nfs_commit_queue_time   =3D n[6].to_f / $nfs_=
nr_commits=0A			$nfs_commit_rtt_time     =3D n[7].to_f / $nfs_nr_commits=0A=
			$nfs_commit_execute_time =3D n[8].to_f / $nfs_nr_commits=0A		end=0A	end=
=0Aend=0A=0Adef write_bw(path)=0A	bw =3D 0 # MB/s=0A	file =3D "#{path}/trac=
e-global_dirty_state-flusher"=0A	cache =3D "#{path}/write-bandwidth"=0A	if =
File.exist?(cache)=0A		cached_bw =3D File.new(cache).readlines=0A		return c=
ached_bw[0].to_f=0A	end=0A	if File.exist?(file)=0A		state =3D File.new(file=
).readlines=0A		n =3D [state.size / 10, 100].min=0A		return 0 if n =3D=3D 0=
=0A		time0, dirty, writeback, unstable, bg_thresh, thresh, limit, dirtied, =
written0 =3D state[0].split=0A		time, dirty, writeback, unstable, bg_thresh=
, thresh, limit, dirtied, written =3D state[-n].split=0A		bw =3D (written.t=
o_i - written0.to_i) / (time.to_f - time0.to_f) / 256=0A		File.open(cache, =
"w") { |f| f.puts "#{bw}" }=0A	end=0A	return bw=0Aend=0A=0Adef add_dd(path)=
=0A	if $cvalue =3D=3D "write_bw"=0A		bw =3D write_bw(path)=0A		return if bw=
 =3D=3D 0 =0A	else=0A		nfs_stats(path)=0A		eval "bw =3D $#{$cvalue}"=0A	end=
=0A	prefix =3D ""=0A	if path =3D~ /(.*\/)(.*)/=0A		prefix =3D $1=0A		path =
=3D $2=0A	end=0A	# nfs-10dd-1M-1p-32069M-20:10-3.1.0-rc4+=0A	path =3D~ /([a=
-z0-9]+)-([0-9]+dd)-(\d+[kM])-(\d+p)-(\d+M)-([0-9M]+):([0-9M]+)-(.*)/;=0A	a=
ll, fs, job, bs, cpu, mem, thresh, bg_thresh, kernel =3D *$~=0A	if ! kernel=
=0A		path =3D~ /([a-z0-9]+)-(fio_[a-z_0-9]+)-(\d+[kM])-(\d+p)-(\d+M)-([0-9M=
]+):([0-9M]+)-(.*)/;=0A		all, fs, job, bs, cpu, mem, thresh, bg_thresh, ker=
nel =3D *$~=0A	end=0A	if ! kernel=0A		path =3D~ /([a-z0-9]+)-(fio_[a-z_0-9]=
+)-(\d+[kM])-(\d+p)-(\d+M)-(.*)/;=0A		all, fs, job, bs, cpu, mem, kernel =
=3D *$~=0A		thresh =3D "20"=0A		bg_thresh =3D "10"=0A	end=0A	m =3D roundUpT=
oNextPowerOfTwo(mem.to_i)=0A	mem =3D "#{m}M"=0A	ckey =3D ""=0A=0A	prefix =
=3D "" if $cfield =3D~ /thresh/=0A	eval "ckey =3D #{$cfield}; #{$cfield} =
=3D 'X'"=0A	if ckey and !$cfield_hash.has_key?(ckey)=0A		$cfield_array.push=
(ckey)=0A		$cfield_hash[ckey] =3D 1=0A		$sum.push 0.0=0A	end=0A	key =3D "#{=
prefix}#{fs}-#{job}-#{bs}-#{cpu}-#{mem}-#{thresh}:#{bg_thresh}-#{kernel}"=
=0A	if !$cases.has_key?(key)=0A		$cases[key] =3D { ckey =3D> bw }=0A	else=
=0A		$cases[key][ckey] =3D bw=0A	end=0A	# print "#{fs}-#{job}-#{mem}-#{bw}\=
n"=0Aend=0A=0AARGV.each { |path|=0A	if path =3D~ $grep=0A		add_dd path=0A	e=
nd=0A}=0A=0Aif $cfield =3D=3D "kernel"=0A	name =3D ""=0Aelse=0A	name =3D $c=
field + "=3D"=0Aend=0A$cfield_array.each { |ckey|=0A	printf "%24s  ", name =
+ ckey=0A}=0Aputs=0A$cfield_array.each {=0A	printf "-----------------------=
-  "=0A}=0Aputs=0A$cases.sort.each { |key, value|=0A	n =3D 0=0A	$cfield_has=
h.each_key { |ckey|=0A		n +=3D 1 if $cases[key][ckey]=0A	}=0A	next if n < 2=
=0A	$cfield_array.each_index { |i|=0A		ckey =3D $cfield_array[i]=0A		bw =3D=
 $cases[key][ckey] || 0=0A		bw0 =3D $cases[key][$cfield_array[0]] || 0=0A		=
if i =3D=3D 0 || bw =3D=3D 0 || bw0 =3D=3D 0=0A			printf "%24.2f  ", bw=0A	=
	else=0A			printf "%+10.1f%% %12.2f  ", 100.0 * (bw - bw0) / bw0, bw=0A		en=
d=0A		$sum[i] +=3D bw=0A	}=0A	printf "%s\n", key=0A}=0A=0Abw0 =3D $sum[0]=
=0A$sum.each_with_index { |bw, i|=0A	if i =3D=3D 0=0A		printf "%24.2f  ", b=
w=0A	else=0A		printf "%+10.1f%% %12.2f  ", 100.0 * (bw - bw0) / bw0, bw=0A	=
end=0A}=0Aputs "TOTAL #{$cvalue}"=0A
--r5Pyd7+fXNt84Ff3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
