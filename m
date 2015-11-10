Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id EA4846B0253
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 15:01:51 -0500 (EST)
Received: by padhx2 with SMTP id hx2so6482372pad.1
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 12:01:51 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id em5si6996529pbd.203.2015.11.10.12.01.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 12:01:50 -0800 (PST)
Received: by padhx2 with SMTP id hx2so6481936pad.1
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 12:01:50 -0800 (PST)
Date: Tue, 10 Nov 2015 12:01:48 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH selftests 5/6] selftests: vm: Try harder to allocate huge
 pages
In-Reply-To: <1446334747.2595.19.camel@decadent.org.uk>
Message-ID: <alpine.DEB.2.10.1511101159480.29993@chino.kir.corp.google.com>
References: <1446334510.2595.13.camel@decadent.org.uk> <1446334747.2595.19.camel@decadent.org.uk>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397176738-1890272663-1447185709=:29993"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ben Hutchings <ben@decadent.org.uk>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-api@vger.kernel.org, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397176738-1890272663-1447185709=:29993
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Sat, 31 Oct 2015, Ben Hutchings wrote:

> If we need to increase the number of huge pages, drop caches first
> to reduce fragmentation and then check that we actually allocated
> as many as we wanted.A A Retry once if that doesn't work.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> The test always fails for me in a 1 GB VM without this.
> 
> Ben.
> 
> A tools/testing/selftests/vm/run_vmtests | 15 ++++++++++++++-
> A 1 file changed, 14 insertions(+), 1 deletion(-)
> 
> diff --git a/tools/testing/selftests/vm/run_vmtests b/tools/testing/selftests/vm/run_vmtests
> index 9179ce8..97ed1b2 100755
> --- a/tools/testing/selftests/vm/run_vmtests
> +++ b/tools/testing/selftests/vm/run_vmtests
> @@ -20,13 +20,26 @@ done < /proc/meminfo
> A if [ -n "$freepgs" ] && [ -n "$pgsize" ]; then
> A 	nr_hugepgs=`cat /proc/sys/vm/nr_hugepages`
> A 	needpgs=`expr $needmem / $pgsize`
> -	if [ $freepgs -lt $needpgs ]; then
> +	tries=2
> +	while [ $tries -gt 0 ] && [ $freepgs -lt $needpgs ]; do
> A 		lackpgs=$(( $needpgs - $freepgs ))
> +		echo 3 > /proc/sys/vm/drop_caches
> A 		echo $(( $lackpgs + $nr_hugepgs )) > /proc/sys/vm/nr_hugepages
> A 		if [ $? -ne 0 ]; then
> A 			echo "Please run this test as root"
> A 			exit 1
> A 		fi
> +		while read name size unit; do
> +			if [ "$name" = "HugePages_Free:" ]; then
> +				freepgs=$size
> +			fi
> +		done < /proc/meminfo
> +		tries=$((tries - 1))
> +	done
> +	if [ $freepgs -lt $needpgs ]; then
> +		printf "Not enough huge pages available (%d < %d)\n" \
> +		A A A A A A A $freepgs $needpgs
> +		exit 1
> A 	fi
> A else
> A 	echo "no hugetlbfs support in kernel?"
> 

I know this patch is in -mm and hasn't been merged by Linus yet, but I'm 
wondering why the multiple /proc/sys/vm/drop_caches is helping?  Would it 
simply suffice to put a sleep in there instead or is drop_caches actually 
doing something useful a second time around?
--397176738-1890272663-1447185709=:29993--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
