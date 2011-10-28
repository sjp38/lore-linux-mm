Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B64006B002D
	for <linux-mm@kvack.org>; Fri, 28 Oct 2011 16:40:06 -0400 (EDT)
Date: Sat, 29 Oct 2011 04:39:44 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [patch 3/5] mm: try to distribute dirty pages fairly across
 zones
Message-ID: <20111028203944.GB20607@localhost>
References: <1317367044-475-1-git-send-email-jweiner@redhat.com>
 <1317367044-475-4-git-send-email-jweiner@redhat.com>
 <20110930142805.GC869@tiehlicka.suse.cz>
 <20111027155618.GA25524@localhost>
 <20111027161359.GA1319@redhat.com>
 <20111027204743.GA19343@localhost>
 <20111027221258.GA22869@localhost>
 <20111027231933.GB1319@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="ZGiS0Q5IWpPtfppv"
Content-Disposition: inline
In-Reply-To: <20111027231933.GB1319@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Chris Mason <chris.mason@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, "Li, Shaohua" <shaohua.li@intel.com>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

[restore CC list]

> > I'm trying to understand where the performance gain comes from.
> > 
> > I noticed that in all cases, before/after patchset, nr_vmscan_write are all zero.
> > 
> > nr_vmscan_immediate_reclaim is significantly reduced though:
> 
> That's a good thing, it means we burn less CPU time on skipping
> through dirty pages on the LRU.
> 
> Until a certain priority level, the dirty pages encountered on the LRU
> list are marked PageReclaim and put back on the list, this is the
> nr_vmscan_immediate_reclaim number.  And only below that priority, we
> actually ask the FS to write them, which is nr_vmscan_write.

Yes, it is.

> I suspect this is where the performance improvement comes from: we
> find clean pages for reclaim much faster.

That explains how it could reduce CPU overheads. However the dd's are
throttled anyway, so I still don't understand how the speedup of dd page
allocations improve the _IO_ performance.

> > $ ./compare.rb -g 1000M -e nr_vmscan_immediate_reclaim thresh*/*-ioless-full-nfs-wq5-next-20111014+ thresh*/*-ioless-full-per-zone-dirty-next-20111014+
> > 3.1.0-rc9-ioless-full-nfs-wq5-next-20111014+  3.1.0-rc9-ioless-full-per-zone-dirty-next-20111014+  
> > ------------------------  ------------------------  
> >                560289.00       -98.5%      8145.00  thresh=1000M/btrfs-100dd-4k-8p-4096M-1000M:10-X
> >                576882.00       -98.4%      9511.00  thresh=1000M/btrfs-10dd-4k-8p-4096M-1000M:10-X
> >                651258.00       -98.8%      7963.00  thresh=1000M/btrfs-1dd-4k-8p-4096M-1000M:10-X
> >               1963294.00       -85.4%    286815.00  thresh=1000M/ext3-100dd-4k-8p-4096M-1000M:10-X
> >               2108028.00       -10.6%   1885114.00  thresh=1000M/ext3-10dd-4k-8p-4096M-1000M:10-X
> >               2499456.00       -99.9%      2061.00  thresh=1000M/ext3-1dd-4k-8p-4096M-1000M:10-X
> >               2534868.00       -78.5%    545815.00  thresh=1000M/ext4-100dd-4k-8p-4096M-1000M:10-X
> >               2921668.00       -76.8%    677177.00  thresh=1000M/ext4-10dd-4k-8p-4096M-1000M:10-X
> >               2841049.00      -100.0%       779.00  thresh=1000M/ext4-1dd-4k-8p-4096M-1000M:10-X
> >               2481823.00       -86.3%    339342.00  thresh=1000M/xfs-100dd-4k-8p-4096M-1000M:10-X
> >               2508629.00       -87.4%    316614.00  thresh=1000M/xfs-10dd-4k-8p-4096M-1000M:10-X
> >               2656628.00      -100.0%       678.00  thresh=1000M/xfs-1dd-4k-8p-4096M-1000M:10-X
> >              24303872.00       -83.2%   4080014.00  TOTAL nr_vmscan_immediate_reclaim
> > 
> > If you'd like to compare any other vmstat items before/after patch,
> > let me know and I'll run the compare script to find them out.
> 
> I will come back to you on this, so tired right now.  But I find your
> scripts interesting ;-) Are those released and available for download
> somewhere?  I suspect every kernel hacker has their own collection of
> scripts to process data like this, maybe we should pull them all
> together and put them into a git tree!

Thank you for the interest :-)

I used to upload my writeback test scripts to kernel.org. However its
file service is not restored yet. So I attach the compare script here.
It's a bit hacky for now, which I hope can be improved over time to be
useful to other projects as well.

Thanks,
Fengguang

--ZGiS0Q5IWpPtfppv
Content-Type: application/x-ruby
Content-Disposition: attachment; filename="compare.rb"
Content-Transfer-Encoding: quoted-printable

#!/usr/bin/ruby=0A=0Arequire 'optparse'=0Arequire 'ostruct'=0A=0ANFS_MNT=3D=
"/fs/nfs"=0A=0A$cfield =3D "kernel"=0A$cfield_hash =3D Hash.new=0A$cfield_a=
rray =3D Array.new=0A$cases =3D Hash.new=0A$sum =3D Array.new=0A$grep =3D /=
/=0A$vgrep =3D /SOME IMPOSSIBLE PATTERN sdfghjkl:1234567890;/=0A=0A$evaluat=
e =3D "write_bw"=0A=0A$nfs_nr_commits =3D 0=0A$nfs_nr_writes =3D 0=0A=0A$nf=
s_write_total =3D 0=0A$nfs_commit_size =3D 0=0A$nfs_write_size =3D 0=0A=0A$=
nfs_write_queue_time =3D 0=0A$nfs_write_rtt_time =3D 0=0A$nfs_write_execute=
_time =3D 0=0A=0A$nfs_commit_queue_time =3D 0=0A$nfs_commit_rtt_time =3D 0=
=0A$nfs_commit_execute_time =3D 0=0A=0Aopts =3D OptionParser.new do |opts|=
=0A        opts.banner =3D "Usage: compare.rb [options] cases..."=0A=0A    =
    opts.separator ""=0A        opts.separator "options:"=0A=0A        opts=
=2Eon("-c FIELD", "--compare FIELD", "compare FIELD: fs/kernel/job/thresh/b=
g_thresh") do |field|=0A                $cfield =3D field=0A		# puts "#{$cf=
ield}\n"=0A        end=0A       =0A        opts.on("-e FIELD", "--evaluate =
FIELD", "evaluate FIELD: write_bw/nfs_*") do |field|=0A                $eva=
luate =3D field=0A        end=0A       =0A        opts.on("-g PATTERN", "--=
grep PATTERN", "only compare cases that match PATTERN") do |pattern|=0A    =
            $grep =3D Regexp.new(pattern)=0A        end=0A       =0A       =
 opts.on("-v PATTERN", "--reverse-grep PATTERN", "exclude cases that match =
PATTERN") do |pattern|=0A                $vgrep =3D Regexp.new(pattern)=0A =
       end=0A       =0A        opts.on_tail("-h", "--help", "Show this mess=
age") do=0A                puts opts=0A                exit=0A        end=
=0A=0Aend=0A=0Aopts.parse!(ARGV)=0A=0A# http://bits.stephan-brumme.com/roun=
dUpToNextPowerOfTwo.html=0Adef roundUpToNextPowerOfTwo(x)=0A	x -=3D 1=0A	x =
|=3D x >> 1;  # handle  2 bit numbers=0A	x |=3D x >> 2;  # handle  4 bit nu=
mbers=0A	x |=3D x >> 4;  # handle  8 bit numbers=0A	x |=3D x >> 8;  # handl=
e 16 bit numbers=0A	x |=3D x >> 16; # handle 32 bit numbers=0A	x +=3D 1=0A	=
return x;=0Aend=0A=0Adef iostat_cpu(path)=0A	file =3D "#{path}/iostat-cpu"=
=0A	eval "$#{$evaluate} =3D 0"=0A	vars=3D["user", "nice", "system", "iowait=
", "steal", "idle"]=0A	vars.each { |var| eval "$cpu_#{var} =3D 0.0" }=0A	re=
turn if not File.exist?(file)=0A	stat =3D File.new(file).readlines=0A	stat.=
each_with_index do |line, i|=0A		next if i < 3=0A		vals =3D line.split=0A		=
vars.each_with_index { |var, i| eval "$cpu_#{var} +=3D #{vals[i]}" }=0A	end=
=0A	vars.each { |var| eval "$cpu_#{var} /=3D #{stat.size-3}" }=0Aend=0A=0Ad=
ef vmstat(path)=0A	file =3D "#{path}/vmstat-end"=0A	eval "$#{$evaluate} =3D=
 0"=0A	return if not File.exist?(file)=0A	=0A	stat =3D File.new(file).readl=
ines=0A	stat.each do |line|=0A		var, val =3D line.split=0A		eval "$#{var} =
=3D #{val}"=0A	end=0Aend=0A=0Adef nfs_stats(path)=0A	file =3D "#{path}/moun=
tstats-end"=0A=0A	$nfs_nr_commits =3D 0=0A	$nfs_nr_writes =3D 0=0A=0A	$nfs_=
write_mb =3D 0=0A	$nfs_nr_commits_per_mb =3D 0=0A	$nfs_nr_writes_per_mb =3D=
 0=0A=0A	$nfs_write_queue_time =3D 0=0A	$nfs_write_rtt_time =3D 0=0A	$nfs_w=
rite_execute_time =3D 0=0A=0A	$nfs_commit_queue_time =3D 0=0A	$nfs_commit_r=
tt_time =3D 0=0A	$nfs_commit_execute_time =3D 0=0A=0A	return if not File.ex=
ist?(file)=0A	=0A	stat =3D File.new(file).readlines=0A	nfsmnt =3D nil=0A	st=
at.each do |line|=0A		if line.index("mounted on /")=0A			nfsmnt =3D line.in=
dex("mounted on #{NFS_MNT}")=0A		end=0A		next unless nfsmnt=0A		if line.ind=
ex("WRITE: ")=0A			n =3D line.split=0A			$nfs_nr_writes =3D n[1].to_i=0A			=
next if $nfs_nr_writes =3D=3D 0=0A			$nfs_write_total =3D n[4].to_f=0A			$n=
fs_write_size =3D $nfs_write_total / $nfs_nr_writes / (1<<20)=0A			$nfs_wri=
te_queue_time   =3D n[6].to_f / $nfs_nr_writes=0A			$nfs_write_rtt_time    =
 =3D n[7].to_f / $nfs_nr_writes=0A			$nfs_write_execute_time =3D n[8].to_f =
/ $nfs_nr_writes=0A			# puts line=0A			# puts $nfs_nr_writes=0A		end=0A		if=
 line.index("COMMIT: ")=0A			n =3D line.split=0A			$nfs_nr_commits =3D n[1]=
=2Eto_i=0A			next if $nfs_nr_commits =3D=3D 0=0A			$nfs_commit_size =3D $nf=
s_write_total / $nfs_nr_commits / (1<<20)=0A			$nfs_commit_queue_time   =3D=
 n[6].to_f / $nfs_nr_commits=0A			$nfs_commit_rtt_time     =3D n[7].to_f / =
$nfs_nr_commits=0A			$nfs_commit_execute_time =3D n[8].to_f / $nfs_nr_commi=
ts=0A		end=0A	end=0Aend=0A=0Adef write_bw(path)=0A	bw =3D 0 # MB/s=0A	file =
=3D "#{path}/trace-global_dirty_state-flusher"=0A	cache =3D "#{path}/write-=
bandwidth"=0A	if File.exist?(cache)=0A		cached_bw =3D File.new(cache).readl=
ines=0A		return cached_bw[0].to_f=0A	end=0A	if File.exist?(file)=0A		state =
=3D File.new(file).readlines=0A		n =3D [state.size / 10, 100].min=0A		retur=
n 0 if n =3D=3D 0=0A		time0, dirty, writeback, unstable, bg_thresh, thresh,=
 limit, dirtied, written0 =3D state[0].split=0A		time, dirty, writeback, un=
stable, bg_thresh, thresh, limit, dirtied, written =3D state[-n].split=0A		=
bw =3D (written.to_i - written0.to_i) / (time.to_f - time0.to_f) / 256=0A		=
File.open(cache, "w") { |f| f.puts "#{bw}" }=0A	end=0A	return bw=0Aend=0A=
=0Adef add_dd(path)=0A	if $evaluate =3D=3D "write_bw"=0A		bw =3D write_bw(p=
ath)=0A		return if bw =3D=3D 0 =0A	elsif $evaluate.index("nfs_") =3D=3D 0=
=0A		nfs_stats(path)=0A		eval "bw =3D $#{$evaluate}"=0A	elsif $evaluate.ind=
ex("cpu_") =3D=3D 0=0A		iostat_cpu(path)=0A		eval "bw =3D $#{$evaluate}"=0A=
	else=0A		vmstat(path)=0A		eval "bw =3D $#{$evaluate}"=0A	end=0A	prefix =3D=
 ""=0A	if path =3D~ /(.*\/)(.*)/=0A		prefix =3D $1=0A		path =3D $2=0A	end=
=0A	# nfs-10dd-1M-1p-32069M-20:10-3.1.0-rc4+=0A	path =3D~ /([a-z0-9]+)-([0-=
9]+dd)-(\d+[kMg])-(\d+p)-(\d+M)-([0-9M]+):([0-9M]+)-(.*)/;=0A	all, fs, job,=
 bs, cpu, mem, thresh, bg_thresh, kernel =3D *$~=0A	if ! kernel=0A		path =
=3D~ /([a-z0-9]+)-(fio_[a-z_0-9]+)-(\d+[kM])-(\d+p)-(\d+M)-([0-9M]+):([0-9M=
]+)-(.*)/;=0A		all, fs, job, bs, cpu, mem, thresh, bg_thresh, kernel =3D *$=
~=0A	end=0A	if ! kernel=0A		path =3D~ /([a-z0-9]+)-(fio_[a-z_0-9]+)-(\d+[kM=
])-(\d+p)-(\d+M)-(.*)/;=0A		all, fs, job, bs, cpu, mem, kernel =3D *$~=0A		=
thresh =3D "20"=0A		bg_thresh =3D "10"=0A	end=0A	m =3D roundUpToNextPowerOf=
Two(mem.to_i)=0A	mem =3D "#{m}M"=0A	ckey =3D ""=0A=0A	prefix =3D "" if $cfi=
eld =3D~ /thresh/=0A	eval "ckey =3D #{$cfield}; #{$cfield} =3D 'X'"=0A	if c=
key and !$cfield_hash.has_key?(ckey)=0A		$cfield_array.push(ckey)=0A		$cfie=
ld_hash[ckey] =3D 1=0A		$sum.push 0.0=0A	end=0A	# bs=3D"4k"=0A	key =3D "#{p=
refix}#{fs}-#{job}-#{bs}-#{cpu}-#{mem}-#{thresh}:#{bg_thresh}-#{kernel}"=0A=
	if !$cases.has_key?(key)=0A		$cases[key] =3D { ckey =3D> bw }=0A	else=0A		=
$cases[key][ckey] =3D bw=0A	end=0A	# print "#{fs}-#{job}-#{mem}-#{bw}\n"=0A=
end=0A=0AARGV.each { |path|=0A	if path =3D~ $grep and not path =3D~ $vgrep=
=0A		add_dd path=0A	end=0A}=0A=0Aif $cfield =3D~ /thresh|mem/=0A	name =3D $=
cfield + "=3D"=0Aelse=0A	name =3D ""=0Aend=0A$cfield_array.each { |ckey|=0A=
	printf "%24s  ", name + ckey=0A}=0Aputs=0A$cfield_array.each {=0A	printf "=
------------------------  "=0A}=0Aputs=0A$cases.sort.each { |key, value|=0A=
	n =3D 0=0A	$cfield_hash.each_key { |ckey|=0A		n +=3D 1 if $cases[key][ckey=
]=0A	}=0A	next if n < 2=0A	$cfield_array.each_index { |i|=0A		ckey =3D $cfi=
eld_array[i]=0A		bw =3D $cases[key][ckey] || 0=0A		bw0 =3D $cases[key][$cfi=
eld_array[0]] || 0=0A		if i =3D=3D 0 || bw =3D=3D 0 || bw0 =3D=3D 0=0A			pr=
intf "%24.2f  ", bw=0A		else=0A			printf "%+10.1f%% %12.2f  ", 100.0 * (bw =
- bw0) / bw0, bw=0A		end=0A		$sum[i] +=3D bw=0A	}=0A	printf "%s\n", key=0A}=
=0A=0Abw0 =3D $sum[0]=0A$sum.each_with_index { |bw, i|=0A	if i =3D=3D 0=0A	=
	printf "%24.2f  ", bw=0A	else=0A		printf "%+10.1f%% %12.2f  ", 100.0 * (bw=
 - bw0) / bw0, bw=0A	end=0A}=0Aputs "TOTAL #{$evaluate}"=0A
--ZGiS0Q5IWpPtfppv--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
