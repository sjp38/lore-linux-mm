Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 523F76B0253
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 15:06:05 -0500 (EST)
Received: by pasz6 with SMTP id z6so6748471pas.2
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 12:06:05 -0800 (PST)
Received: from lists.s-osg.org (lists.s-osg.org. [54.187.51.154])
        by mx.google.com with ESMTP id yp1si7043734pbc.152.2015.11.10.12.06.03
        for <linux-mm@kvack.org>;
        Tue, 10 Nov 2015 12:06:03 -0800 (PST)
Subject: Re: [PATCH selftests 5/6] selftests: vm: Try harder to allocate huge
 pages
References: <1446334510.2595.13.camel@decadent.org.uk>
 <1446334747.2595.19.camel@decadent.org.uk>
 <alpine.DEB.2.10.1511101159480.29993@chino.kir.corp.google.com>
From: Shuah Khan <shuahkh@osg.samsung.com>
Message-ID: <56424E1F.9040507@osg.samsung.com>
Date: Tue, 10 Nov 2015 13:05:51 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1511101159480.29993@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Ben Hutchings <ben@decadent.org.uk>
Cc: linux-api@vger.kernel.org, linux-mm@kvack.org, Shuah Khan <shuahkh@osg.samsung.com>

On 11/10/2015 01:01 PM, David Rientjes wrote:
> On Sat, 31 Oct 2015, Ben Hutchings wrote:
> 
>> If we need to increase the number of huge pages, drop caches first
>> to reduce fragmentation and then check that we actually allocated
>> as many as we wanted.  Retry once if that doesn't work.
>>
>> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
>> ---
>> The test always fails for me in a 1 GB VM without this.
>>
>> Ben.
>>
>>  tools/testing/selftests/vm/run_vmtests | 15 ++++++++++++++-
>>  1 file changed, 14 insertions(+), 1 deletion(-)
>>
>> diff --git a/tools/testing/selftests/vm/run_vmtests b/tools/testing/selftests/vm/run_vmtests
>> index 9179ce8..97ed1b2 100755
>> --- a/tools/testing/selftests/vm/run_vmtests
>> +++ b/tools/testing/selftests/vm/run_vmtests
>> @@ -20,13 +20,26 @@ done < /proc/meminfo
>>  if [ -n "$freepgs" ] && [ -n "$pgsize" ]; then
>>  	nr_hugepgs=`cat /proc/sys/vm/nr_hugepages`
>>  	needpgs=`expr $needmem / $pgsize`
>> -	if [ $freepgs -lt $needpgs ]; then
>> +	tries=2
>> +	while [ $tries -gt 0 ] && [ $freepgs -lt $needpgs ]; do
>>  		lackpgs=$(( $needpgs - $freepgs ))
>> +		echo 3 > /proc/sys/vm/drop_caches
>>  		echo $(( $lackpgs + $nr_hugepgs )) > /proc/sys/vm/nr_hugepages
>>  		if [ $? -ne 0 ]; then
>>  			echo "Please run this test as root"
>>  			exit 1
>>  		fi
>> +		while read name size unit; do
>> +			if [ "$name" = "HugePages_Free:" ]; then
>> +				freepgs=$size
>> +			fi
>> +		done < /proc/meminfo
>> +		tries=$((tries - 1))
>> +	done
>> +	if [ $freepgs -lt $needpgs ]; then
>> +		printf "Not enough huge pages available (%d < %d)\n" \
>> +		       $freepgs $needpgs
>> +		exit 1
>>  	fi
>>  else
>>  	echo "no hugetlbfs support in kernel?"
>>
> 
> I know this patch is in -mm and hasn't been merged by Linus yet, but I'm 
> wondering why the multiple /proc/sys/vm/drop_caches is helping?  Would it 
> simply suffice to put a sleep in there instead or is drop_caches actually 
> doing something useful a second time around?
> 

I sent this up for merge in my pull request. Adding sleep would increase
test run-time. Something to keep in mind.

thanks,
-- Shuah

-- 
Shuah Khan
Sr. Linux Kernel Developer
Open Source Innovation Group
Samsung Research America (Silicon Valley)
shuahkh@osg.samsung.com | (970) 217-8978

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
