Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 203F49000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 10:02:11 -0400 (EDT)
Date: Wed, 28 Sep 2011 22:02:05 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 10/18] writeback: dirty position control - bdi reserve
 area
Message-ID: <20110928140205.GA26617@localhost>
References: <20110904015305.367445271@intel.com>
 <20110904020915.942753370@intel.com>
 <1315318179.14232.3.camel@twins>
 <20110907123108.GB6862@localhost>
 <1315822779.26517.23.camel@twins>
 <20110918141705.GB15366@localhost>
 <20110918143721.GA17240@localhost>
 <20110918144751.GA18645@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="tKW2IUtsqtDRztdT"
Content-Disposition: inline
In-Reply-To: <20110918144751.GA18645@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


--tKW2IUtsqtDRztdT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Peter,

On Sun, Sep 18, 2011 at 10:47:51PM +0800, Wu Fengguang wrote:
> > BTW, I also compared the IO-less patchset and the vanilla kernel's
> > JBOD performance. Basically, the performance is lightly improved
> > under large memory, and reduced a lot in small memory servers.
> > 
> >  vanillla IO-less  
> > --------------------------------------------------------------------------------
> [...]
> >  26508063 17706200      -33.2%  JBOD-10HDD-thresh=100M/xfs-100dd-1M-16p-5895M-100M
> >  23767810 23374918       -1.7%  JBOD-10HDD-thresh=100M/xfs-10dd-1M-16p-5895M-100M
> >  28032891 20659278      -26.3%  JBOD-10HDD-thresh=100M/xfs-1dd-1M-16p-5895M-100M
> >  26049973 22517497      -13.6%  JBOD-10HDD-thresh=100M/xfs-2dd-1M-16p-5895M-100M
> > 
> > There are still some itches in JBOD..
> 
> OK, in the dirty_bytes=100M case, I find that the bdi threshold _and_
> writeout bandwidth may drop close to 0 in long periods. This change
> may avoid one bdi being stuck:
> 
>         /*
>          * bdi reserve area, safeguard against dirty pool underrun and disk idle
>          *
>          * It may push the desired control point of global dirty pages higher
>          * than setpoint. It's not necessary in single-bdi case because a
>          * minimal pool of @freerun dirty pages will already be guaranteed.
>          */
> -       x_intercept = min(write_bw, freerun);
> +       x_intercept = min(write_bw + MIN_WRITEBACK_PAGES, freerun);

After lots of experiments, I end up with this bdi reserve point

+       x_intercept = bdi_thresh / 2 + MIN_WRITEBACK_PAGES;

together with this chunk to avoid a bdi stuck in bdi_thresh=0 state:

@@ -590,6 +590,7 @@ static unsigned long bdi_position_ratio(
         */
        if (unlikely(bdi_thresh > thresh))
                bdi_thresh = thresh;
+       bdi_thresh = max(bdi_thresh, (limit - dirty) / 8);
        /*
         * scale global setpoint to bdi's:
         *      bdi_setpoint = setpoint * bdi_thresh / thresh

The above changes are good enough to keep reasonable amount of bdi
dirty pages, so the bdi underrun flag ("[PATCH 11/18] block: add bdi
flag to indicate risk of io queue underrun") is dropped.

I also tried various bdi freerun patches, however the results are not
satisfactory. Basically the bdi reserve area approach (this patch)
yields noticeably more smooth/resilient behavior than the
freerun/underrun approaches. I noticed that the bdi underrun flag
could lead to sudden surge of dirty pages (especially if not
safeguarded by the dirty_exceeded condition) in the very small
window..

To dig performance increases/drops out of the large number of test
results, I wrote a convenient script (attached) to compare the
vmstat:nr_written numbers between 2+ set of test runs. It helped a lot
for fine tuning the parameters for different cases.

The current JBOD performance numbers are encouraging:

$ ./compare.rb JBOD*/*-vanilla+ JBOD*/*-bgthresh3+
      3.1.0-rc4-vanilla+      3.1.0-rc4-bgthresh3+
------------------------  ------------------------
                52934365        +3.2%     54643527  JBOD-10HDD-thresh=100M/ext4-100dd-1M-24p-16384M-100M:10-X
                45488896       +18.2%     53785605  JBOD-10HDD-thresh=100M/ext4-10dd-1M-24p-16384M-100M:10-X
                47217534       +12.2%     53001031  JBOD-10HDD-thresh=100M/ext4-1dd-1M-24p-16384M-100M:10-X
                32286924       +25.4%     40492312  JBOD-10HDD-thresh=100M/xfs-10dd-1M-24p-16384M-100M:10-X
                38676965       +14.2%     44177606  JBOD-10HDD-thresh=100M/xfs-1dd-1M-24p-16384M-100M:10-X
                59662173       +11.1%     66269621  JBOD-10HDD-thresh=800M/ext4-10dd-1M-24p-16384M-800M:10-X
                57510438        +2.3%     58855181  JBOD-10HDD-thresh=800M/ext4-1dd-1M-24p-16384M-800M:10-X
                63691922       +64.0%    104460352  JBOD-10HDD-thresh=800M/xfs-100dd-1M-24p-16384M-800M:10-X
                51978567       +16.0%     60298210  JBOD-10HDD-thresh=800M/xfs-10dd-1M-24p-16384M-800M:10-X
                47641062        +6.4%     50681038  JBOD-10HDD-thresh=800M/xfs-1dd-1M-24p-16384M-800M:10-X

The common single disk cases also see good numbers except for slight
drops in the dirty_bytes=100MB case:

$ ./compare.rb thresh*/*vanilla+ thresh*/*bgthresh3+
      3.1.0-rc4-vanilla+      3.1.0-rc4-bgthresh3+  
------------------------  ------------------------  
                 4092719        -2.5%      3988742  thresh=100M/ext4-10dd-4k-8p-4096M-100M:10-X
                 4956323        -4.0%      4758884  thresh=100M/ext4-1dd-4k-8p-4096M-100M:10-X
                 4640118        -0.4%      4621240  thresh=100M/ext4-2dd-4k-8p-4096M-100M:10-X
                 3545136        -3.5%      3420717  thresh=100M/xfs-10dd-4k-8p-4096M-100M:10-X
                 4399437        -0.9%      4361830  thresh=100M/xfs-1dd-4k-8p-4096M-100M:10-X
                 4100655        -3.3%      3964043  thresh=100M/xfs-2dd-4k-8p-4096M-100M:10-X
                 4780624        -0.1%      4776216  thresh=1G/ext4-10dd-4k-8p-4096M-1024M:10-X
                 4904565        +0.0%      4905293  thresh=1G/ext4-1dd-4k-8p-4096M-1024M:10-X
                 3578539        +9.1%      3903390  thresh=1G/xfs-10dd-4k-8p-4096M-1024M:10-X
                 4029890        +0.8%      4063717  thresh=1G/xfs-1dd-4k-8p-4096M-1024M:10-X
                 2449031       +20.0%      2937926  thresh=1M/ext4-10dd-4k-8p-4096M-1M:10-X
                 4161896        +7.5%      4472552  thresh=1M/ext4-1dd-4k-8p-4096M-1M:10-X
                 3437787       +18.8%      4085707  thresh=1M/ext4-2dd-4k-8p-4096M-1M:10-X
                 1921914       +14.8%      2206897  thresh=1M/xfs-10dd-4k-8p-4096M-1M:10-X
                 2537481       +65.8%      4207336  thresh=1M/xfs-1dd-4k-8p-4096M-1M:10-X
                 3329176       +12.3%      3739888  thresh=1M/xfs-2dd-4k-8p-4096M-1M:10-X
                 4587856        +1.8%      4672501  thresh=400M-300M/ext4-10dd-4k-8p-4096M-400M:300M-X
                 4883525        +0.0%      4884957  thresh=400M-300M/ext4-1dd-4k-8p-4096M-400M:300M-X
                 4799105        +2.3%      4907525  thresh=400M-300M/ext4-2dd-4k-8p-4096M-400M:300M-X
                 3931315        +3.0%      4048277  thresh=400M-300M/xfs-10dd-4k-8p-4096M-400M:300M-X
                 4238389        +3.9%      4401927  thresh=400M-300M/xfs-1dd-4k-8p-4096M-400M:300M-X
                 4032798        +2.3%      4123838  thresh=400M-300M/xfs-2dd-4k-8p-4096M-400M:300M-X
                 2425253       +35.2%      3279302  thresh=8M/ext4-10dd-4k-8p-4096M-8M:10-X
                 4728506        +2.2%      4834878  thresh=8M/ext4-1dd-4k-8p-4096M-8M:10-X
                 2782860       +62.1%      4511120  thresh=8M/ext4-2dd-4k-8p-4096M-8M:10-X
                 1966133       +24.3%      2443874  thresh=8M/xfs-10dd-4k-8p-4096M-8M:10-X
                 4238402        +1.7%      4308416  thresh=8M/xfs-1dd-4k-8p-4096M-8M:10-X
                 3299446       +13.3%      3739810  thresh=8M/xfs-2dd-4k-8p-4096M-8M:10-X

Thanks,
Fengguang

--tKW2IUtsqtDRztdT
Content-Type: application/x-ruby
Content-Disposition: attachment; filename="compare.rb"
Content-Transfer-Encoding: quoted-printable

#!/usr/bin/ruby=0A=0Arequire 'optparse'=0Arequire 'ostruct'=0A=0A$cfield =
=3D "kernel"=0A$cfield_hash =3D Hash.new=0A$cfield_array =3D Array.new=0A$c=
ases =3D Hash.new=0A=0Aopts =3D OptionParser.new do |opts|=0A        opts.b=
anner =3D "Usage: compare.rb [options] cases..."=0A=0A        opts.separato=
r ""=0A        opts.separator "options:"=0A=0A        opts.on("-c FIELD", "=
--compare FIELD", "compare FIELD: fs/kernel/nr/thresh") do |field|=0A      =
          $cfield =3D field=0A		# puts "#{$cfield}\n"=0A        end=0A     =
  =0A        opts.on_tail("-h", "--help", "Show this message") do=0A       =
         puts opts=0A                exit=0A        end=0A=0Aend=0A=0Aopts.=
parse!(ARGV)=0A=0A# http://bits.stephan-brumme.com/roundUpToNextPowerOfTwo.=
html=0Adef roundUpToNextPowerOfTwo(x)=0A	x -=3D 1=0A	x |=3D x >> 1;  # hand=
le  2 bit numbers=0A	x |=3D x >> 2;  # handle  4 bit numbers=0A	x |=3D x >>=
 4;  # handle  8 bit numbers=0A	x |=3D x >> 8;  # handle 16 bit numbers=0A	=
x |=3D x >> 16; # handle 32 bit numbers=0A	x +=3D 1=0A	return x;=0Aend=0A=
=0Adef add_dd(path)=0A	# nfs-10dd-1M-1p-32069M-20:10-3.1.0-rc4+=0A	# writte=
n =3D system("grep nr_written #{path}/vmstat-end")=0A	# written =3D written=
[11..-1]=0A	return if ! File.exist?("#{path}/vmstat-end")=0A	vmstat =3D Fil=
e.new("#{path}/vmstat-end").readlines=0A	written =3D 0=0A	vmstat.grep(/nr_w=
ritten (\d+)/) { written =3D $1.to_i }=0A	# File.open("#{path}/vmstat-end")=
=2Eeach_line do |line|=0A	# 	if line =3D~ /nr_written (\d+)/=0A	# 		written=
 =3D $1.to_i=0A	# 		break=0A	# 	end=0A	# end=0A	prefix =3D ""=0A	if path =
=3D~ /(.*\/)(.*)/=0A		prefix =3D $1=0A		path =3D $2=0A	end=0A	path =3D~ /([=
a-z0-9]+)-([0-9]+dd)-(\d+[kM])-(\d+p)-(\d+M)-([0-9M]+):([0-9M]+)-(.*)/;=0A	=
all, fs, dd, bs, cpu, mem, thresh, bg_thresh, kernel =3D *$~=0A	m =3D round=
UpToNextPowerOfTwo(mem.to_i)=0A	mem =3D "#{m}M"=0A	ckey =3D ""=0A	eval "cke=
y =3D #{$cfield}; #{$cfield} =3D 'X'"=0A	$cfield_array.push(ckey) if !$cfie=
ld_hash.has_key?(ckey)=0A	$cfield_hash[ckey] =3D 1=0A	key =3D "#{prefix}#{f=
s}-#{dd}-#{bs}-#{cpu}-#{mem}-#{thresh}:#{bg_thresh}-#{kernel}"=0A	if !$case=
s.has_key?(key)=0A		$cases[key] =3D { ckey =3D> written }=0A	else=0A		$case=
s[key][ckey] =3D written=0A	end=0A	# puts path=0A	# print "#{fs}-#{dd}-#{me=
m}-#{written}\n"=0Aend=0A=0AARGV.each { |path|=0A	add_dd path=0A}=0A=0A$cfi=
eld_array.each { |ckey|=0A	printf "%24s  ", ckey=0A}=0Aputs=0A$cfield_array=
=2Eeach {=0A	printf "------------------------  "=0A}=0Aputs=0A$cases.sort.e=
ach { |key, value|=0A	n =3D 0=0A	$cfield_hash.each_key { |ckey|=0A		n +=3D =
1 if $cases[key][ckey]=0A	}=0A	next if n < 2=0A	$cfield_array.each_index { =
|i|=0A		ckey =3D $cfield_array[i]=0A		written =3D $cases[key][ckey] || 0=0A=
		written0 =3D $cases[key][$cfield_array[0]] || 0=0A		if i =3D=3D 0 || writ=
ten =3D=3D 0 || written0 =3D=3D 0=0A			printf "%24d  ", written=0A		else=0A=
			printf "%+10.1f%% %12d  ", 100.0 * (written - written0) / written0, writ=
ten=0A		end=0A	}=0A	printf "%s\n", key=0A}=0A
--tKW2IUtsqtDRztdT--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
