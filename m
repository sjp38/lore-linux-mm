Return-Path: <SRS0=3rjY=XO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 976FBC4CEC4
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 01:53:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C38D21927
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 01:53:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="IN6CC5Bw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C38D21927
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A246F6B0323; Wed, 18 Sep 2019 21:53:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D3B96B0325; Wed, 18 Sep 2019 21:53:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 875B96B0326; Wed, 18 Sep 2019 21:53:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0064.hostedemail.com [216.40.44.64])
	by kanga.kvack.org (Postfix) with ESMTP id 510AF6B0323
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 21:53:20 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id E8A9C180AD802
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 01:53:19 +0000 (UTC)
X-FDA: 75949997718.04.cow19_9167d6a06641a
X-HE-Tag: cow19_9167d6a06641a
X-Filterd-Recvd-Size: 33756
Received: from mail-oi1-f193.google.com (mail-oi1-f193.google.com [209.85.167.193])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 01:53:19 +0000 (UTC)
Received: by mail-oi1-f193.google.com with SMTP id i16so1376556oie.4
        for <linux-mm@kvack.org>; Wed, 18 Sep 2019 18:53:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=FVNMGIQxrU4S60TP9x2ppS37tvso0QZ99Wlw9x9kuQM=;
        b=IN6CC5Bwv8sNrrkLPkPD2nyCTBZcN5+RZfcgTXoOIM5Xz/HYN7XuLHq/oMbbYwu+SH
         zklmySKYqZfaretjnWWvtZOG8iDRQE6JPYsw7AIOTobRWGK9I8kU5f9VOPQ6XEoBBUja
         h8XDgimN6IG0GqMxUfTupUW2Ucuk74ab6oW/D8427BqqEOivMjrDsmyictN+kGJZYbgn
         h1z2zm/Vo7L9WuzlZdUUBHCN+v+zc8duvdRnu9xoCPu1yYTSlOovLiNvE1HcD4FZSuQG
         nlFoEHYjtGcca0uNz2Vr4d6pybxG0YDP+Lx6F4qWAXNUJZPUpHk3NrD9rIGZTRmUOuwT
         oliw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=FVNMGIQxrU4S60TP9x2ppS37tvso0QZ99Wlw9x9kuQM=;
        b=ISlFT7TB8gtrcOlEi4IR8+poXFIjyVi+DjY2Z1ME+a3Pd+LJLd2ZLTPDPtaD2uw0cJ
         wiVaGCO+27tAVHzU+CazFfofawSuvZcTwqzrpA5hlFHVgoqRzsxb855T0SSprqiB7BKj
         fJfHKDU6IvdICboc4UR0SdenbTJoNEsUojoxgSHoXjIdd5Lr9C8YvziJ/FWcTyP1clHt
         2j2xdp93nMEoCTx7f35muy4roP2YVUo4DeA3ZM5jJoTmEANVoO1TP+j+gYlx7y4S4f0A
         eN8QmOBuP1FlPtMeovnm5NCG1DASGBph6ICC56bFcbGymskoqfqZjmHKbloxLUESAcGl
         IFXQ==
X-Gm-Message-State: APjAAAVkkwu6FYEqXySYLuQOWN+Xp66ntHEqAUA9fjIoBspeMWvdq4yR
	+JjEG+4jxTYUNR1NqgovbgbMSgwMLPsUn84dgQmORg==
X-Google-Smtp-Source: APXvYqzj41J34KRcZNU3Zya3nheWJUSQbRZDAsSU7Zx7QtNOIKuVrGCKXFYMMHZYQZ6jonDaFv4VuaLMhNJCrK/ekMc=
X-Received: by 2002:aca:cf51:: with SMTP id f78mr640002oig.8.1568857997667;
 Wed, 18 Sep 2019 18:53:17 -0700 (PDT)
MIME-Version: 1.0
References: <20190910233146.206080-1-almasrymina@google.com>
 <20190910233146.206080-9-almasrymina@google.com> <4240683f-9fa6-daf8-95ee-259667c87ef7@kernel.org>
In-Reply-To: <4240683f-9fa6-daf8-95ee-259667c87ef7@kernel.org>
From: Mina Almasry <almasrymina@google.com>
Date: Wed, 18 Sep 2019 18:53:05 -0700
Message-ID: <CAHS8izOnJtMFsevb1U0qiBsQsM+UxyO=1F49NKuGrZGwNAz8Yw@mail.gmail.com>
Subject: Re: [PATCH v4 8/9] hugetlb_cgroup: Add hugetlb_cgroup reservation tests
To: shuah <shuah@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, David Rientjes <rientjes@google.com>, 
	Shakeel Butt <shakeelb@google.com>, Greg Thelen <gthelen@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, khalid.aziz@oracle.com, 
	open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, 
	linux-kselftest@vger.kernel.org, cgroups@vger.kernel.org, 
	Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, =?UTF-8?Q?Michal_Koutn=C3=BD?= <mkoutny@suse.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 16, 2019 at 6:52 PM shuah <shuah@kernel.org> wrote:
>
> On 9/10/19 5:31 PM, Mina Almasry wrote:
> > The tests use both shared and private mapped hugetlb memory, and
> > monitors the hugetlb usage counter as well as the hugetlb reservation
> > counter. They test different configurations such as hugetlb memory usage
> > via hugetlbfs, or MAP_HUGETLB, or shmget/shmat, and with and without
> > MAP_POPULATE.
> >
> > Signed-off-by: Mina Almasry <almasrymina@google.com>
> > ---
> >   tools/testing/selftests/vm/.gitignore         |   1 +
> >   tools/testing/selftests/vm/Makefile           |   4 +
> >   .../selftests/vm/charge_reserved_hugetlb.sh   | 440 ++++++++++++++++++
> >   .../selftests/vm/write_hugetlb_memory.sh      |  22 +
> >   .../testing/selftests/vm/write_to_hugetlbfs.c | 252 ++++++++++
> >   5 files changed, 719 insertions(+)
> >   create mode 100755 tools/testing/selftests/vm/charge_reserved_hugetlb.sh
> >   create mode 100644 tools/testing/selftests/vm/write_hugetlb_memory.sh
> >   create mode 100644 tools/testing/selftests/vm/write_to_hugetlbfs.c
> >
> > diff --git a/tools/testing/selftests/vm/.gitignore b/tools/testing/selftests/vm/.gitignore
> > index 31b3c98b6d34d..d3bed9407773c 100644
> > --- a/tools/testing/selftests/vm/.gitignore
> > +++ b/tools/testing/selftests/vm/.gitignore
> > @@ -14,3 +14,4 @@ virtual_address_range
> >   gup_benchmark
> >   va_128TBswitch
> >   map_fixed_noreplace
> > +write_to_hugetlbfs
> > diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
> > index 9534dc2bc9295..8d37d5409b52c 100644
> > --- a/tools/testing/selftests/vm/Makefile
> > +++ b/tools/testing/selftests/vm/Makefile
> > @@ -18,6 +18,7 @@ TEST_GEN_FILES += transhuge-stress
> >   TEST_GEN_FILES += userfaultfd
> >   TEST_GEN_FILES += va_128TBswitch
> >   TEST_GEN_FILES += virtual_address_range
> > +TEST_GEN_FILES += write_to_hugetlbfs
> >
> >   TEST_PROGS := run_vmtests
> >
> > @@ -29,3 +30,6 @@ include ../lib.mk
> >   $(OUTPUT)/userfaultfd: LDLIBS += -lpthread
> >
> >   $(OUTPUT)/mlock-random-test: LDLIBS += -lcap
> > +
> > +# Why does adding $(OUTPUT)/ like above not apply this flag..?
>
> Can you verify the following and remove this comment, once you figure
> out if you need $(OUTPUT)/
> > +write_to_hugetlbfs: CFLAGS += -static
>
> It should. Did you test "make O=" and "KBUILD_OUTPUT" kselftest
> use-cases?
>

Turns out I don't need -static actually.

> > diff --git a/tools/testing/selftests/vm/charge_reserved_hugetlb.sh b/tools/testing/selftests/vm/charge_reserved_hugetlb.sh
> > new file mode 100755
> > index 0000000000000..09e90e8f6fab4
> > --- /dev/null
> > +++ b/tools/testing/selftests/vm/charge_reserved_hugetlb.sh
> > @@ -0,0 +1,440 @@
> > +#!/bin/sh
> > +# SPDX-License-Identifier: GPL-2.0
> > +
> > +set -e
> > +
> > +cgroup_path=/dev/cgroup/memory
> > +if [[ ! -e $cgroup_path ]]; then
> > +      mkdir -p $cgroup_path
> > +      mount -t cgroup -o hugetlb,memory cgroup $cgroup_path
> > +fi
> > +
>
> Does this test need root access? If yes, please add root check
> and skip the test when a non-root runs the test.
>
> > +cleanup () {
> > +     echo $$ > $cgroup_path/tasks
> > +
> > +     set +e
> > +     if [[ "$(pgrep write_to_hugetlbfs)" != "" ]]; then
> > +           kill -2 write_to_hugetlbfs
> > +           # Wait for hugetlbfs memory to get depleted.
> > +           sleep 0.5
>
> This time looks arbitrary. How can you be sure it gets depleted?
> Is there another way to check for it.
>
> > +     fi
> > +     set -e
> > +
> > +     if [[ -e /mnt/huge ]]; then
> > +           rm -rf /mnt/huge/*
> > +           umount /mnt/huge || echo error
> > +           rmdir /mnt/huge
> > +     fi
> > +     if [[ -e $cgroup_path/hugetlb_cgroup_test ]]; then
> > +           rmdir $cgroup_path/hugetlb_cgroup_test
> > +     fi
> > +     if [[ -e $cgroup_path/hugetlb_cgroup_test1 ]]; then
> > +           rmdir $cgroup_path/hugetlb_cgroup_test1
> > +     fi
> > +     if [[ -e $cgroup_path/hugetlb_cgroup_test2 ]]; then
> > +           rmdir $cgroup_path/hugetlb_cgroup_test2
> > +     fi
> > +     echo 0 > /proc/sys/vm/nr_hugepages
> > +     echo CLEANUP DONE
> > +}
> > +
> > +cleanup
> > +
> > +function expect_equal() {
> > +      local expected="$1"
> > +      local actual="$2"
> > +      local error="$3"
> > +
> > +      if [[ "$expected" != "$actual" ]]; then
> > +         echo "expected ($expected) != actual ($actual): $3"
> > +         cleanup
> > +         exit 1
> > +      fi
> > +}
> > +
> > +function setup_cgroup() {
> > +      local name="$1"
> > +      local cgroup_limit="$2"
> > +      local reservation_limit="$3"
> > +
> > +      mkdir $cgroup_path/$name
> > +
> > +      echo writing cgroup limit: "$cgroup_limit"
> > +      echo "$cgroup_limit" > $cgroup_path/$name/hugetlb.2MB.limit_in_bytes
> > +
> > +      echo writing reseravation limit: "$reservation_limit"
> > +      echo "$reservation_limit" > \
> > +         $cgroup_path/$name/hugetlb.2MB.reservation_limit_in_bytes
> > +      echo 0 > $cgroup_path/$name/cpuset.cpus
> > +      echo 0 > $cgroup_path/$name/cpuset.mems
> > +}
> > +
> > +function write_hugetlbfs_and_get_usage() {
> > +      local cgroup="$1"
> > +      local size="$2"
> > +      local populate="$3"
> > +      local write="$4"
> > +      local path="$5"
> > +      local method="$6"
> > +      local private="$7"
> > +      local expect_failure="$8"
> > +
> > +      # Function return values.
> > +      reservation_failed=0
> > +      oom_killed=0
> > +      hugetlb_difference=0
> > +      reserved_difference=0
> > +
> > +      local hugetlb_usage=$cgroup_path/$cgroup/hugetlb.2MB.usage_in_bytes
> > +      local reserved_usage=$cgroup_path/$cgroup/hugetlb.2MB.reservation_usage_in_bytes
> > +
> > +      local hugetlb_before=$(cat $hugetlb_usage)
> > +      local reserved_before=$(cat $reserved_usage)
> > +
> > +      echo
> > +      echo Starting:
> > +      echo hugetlb_usage="$hugetlb_before"
> > +      echo reserved_usage="$reserved_before"
> > +      echo expect_failure is "$expect_failure"
> > +
> > +      set +e
> > +      if [[ "$method" == "1" ]] || [[ "$method" == 2 ]] || \
> > +         [[ "$private" == "-r" ]] && [[ "$expect_failure" != 1 ]]; then
> > +         bash write_hugetlb_memory.sh "$size" "$populate" "$write" \
> > +               "$cgroup"  "$path" "$method" "$private" "-l" &
> > +
> > +         local write_result=$?
> > +         # This sleep is to make sure that the script above has had enough
> > +         # time to do its thing, since it runs in the background. This may
> > +         # cause races...
> > +         sleep 0.5
>
> I am not happy with these arbitrary sleep times, especially coupled with
> the comment about races above. :)
>
> > +         echo write_result is $write_result
> > +      else
> > +         bash write_hugetlb_memory.sh "$size" "$populate" "$write" \
> > +               "$cgroup"  "$path" "$method" "$private"
> > +         local write_result=$?
> > +      fi
> > +      set -e
> > +
> > +      if [[ "$write_result" == 1 ]]; then
> > +         reservation_failed=1
> > +      fi
> > +
> > +      # On linus/master, the above process gets SIGBUS'd on oomkill, with
> > +      # return code 135. On earlier kernels, it gets actual oomkill, with return
> > +      # code 137, so just check for both conditions incase we're testing against
>
> in case
>
> > +      # an earlier kernel.
> > +      if [[ "$write_result" == 135 ]] || [[ "$write_result" == 137 ]]; then
>
> Please add defines for these return values.
>

There is comment that explains this line. Not enough clarity?

> > +         oom_killed=1
> > +      fi
> > +
> > +      local hugetlb_after=$(cat $hugetlb_usage)
> > +      local reserved_after=$(cat $reserved_usage)
> > +
> > +      echo After write:
> > +      echo hugetlb_usage="$hugetlb_after"
> > +      echo reserved_usage="$reserved_after"
> > +
> > +      hugetlb_difference=$(($hugetlb_after - $hugetlb_before))
> > +      reserved_difference=$(($reserved_after - $reserved_before))
> > +}
> > +
> > +function cleanup_hugetlb_memory() {
> > +      set +e
> > +      if [[ "$(pgrep write_to_hugetlbfs)" != "" ]]; then
> > +         echo kiling write_to_hugetlbfs
> > +         killall -2 write_to_hugetlbfs
> > +         # Wait for hugetlbfs memory to get depleted.
> > +         sleep 0.5
>
> Sleep time? Rationale for this number?
>
> > +      fi
> > +      set -e
> > +
> > +      if [[ -e /mnt/huge ]]; then
> > +         rm -rf /mnt/huge/*
> > +           umount /mnt/huge
> > +           rmdir /mnt/huge
> > +      fi
> > +}
> > +
> > +function run_test() {
> > +      local size="$1"
> > +      local populate="$2"
> > +      local write="$3"
> > +      local cgroup_limit="$4"
> > +      local reservation_limit="$5"
> > +      local nr_hugepages="$6"
> > +      local method="$7"
> > +      local private="$8"
> > +      local expect_failure="$9"
> > +
> > +      # Function return values.
> > +      hugetlb_difference=0
> > +      reserved_difference=0
> > +      reservation_failed=0
> > +      oom_killed=0
> > +
> > +      echo nr hugepages = "$nr_hugepages"
> > +      echo "$nr_hugepages" > /proc/sys/vm/nr_hugepages
> > +
> > +      setup_cgroup "hugetlb_cgroup_test" "$cgroup_limit" "$reservation_limit"
> > +
> > +      mkdir -p /mnt/huge
> > +      mount -t hugetlbfs \
> > +         -o pagesize=2M,size=256M none /mnt/huge
> > +
> > +      write_hugetlbfs_and_get_usage "hugetlb_cgroup_test" "$size" "$populate" \
> > +         "$write" "/mnt/huge/test" "$method" "$private" "$expect_failure"
> > +
> > +      cleanup_hugetlb_memory
> > +
> > +      local final_hugetlb=$(cat $cgroup_path/hugetlb_cgroup_test/hugetlb.2MB.usage_in_bytes)
> > +      local final_reservation=$(cat $cgroup_path/hugetlb_cgroup_test/hugetlb.2MB.reservation_usage_in_bytes)
> > +
> > +      expect_equal "0" "$final_hugetlb" "final hugetlb is not zero"
> > +      expect_equal "0" "$final_reservation" "final reservation is not zero"
> > +}
> > +
> > +function run_multiple_cgroup_test() {
> > +      local size1="$1"
> > +      local populate1="$2"
> > +      local write1="$3"
> > +      local cgroup_limit1="$4"
> > +      local reservation_limit1="$5"
> > +
> > +      local size2="$6"
> > +      local populate2="$7"
> > +      local write2="$8"
> > +      local cgroup_limit2="$9"
> > +      local reservation_limit2="${10}"
> > +
> > +      local nr_hugepages="${11}"
> > +      local method="${12}"
> > +      local private="${13}"
> > +      local expect_failure="${14}"
> > +
> > +      # Function return values.
> > +      hugetlb_difference1=0
> > +      reserved_difference1=0
> > +      reservation_failed1=0
> > +      oom_killed1=0
> > +
> > +      hugetlb_difference2=0
> > +      reserved_difference2=0
> > +      reservation_failed2=0
> > +      oom_killed2=0
> > +
> > +
> > +      echo nr hugepages = "$nr_hugepages"
> > +      echo "$nr_hugepages" > /proc/sys/vm/nr_hugepages
> > +
> > +      setup_cgroup "hugetlb_cgroup_test1" "$cgroup_limit1" "$reservation_limit1"
> > +      setup_cgroup "hugetlb_cgroup_test2" "$cgroup_limit2" "$reservation_limit2"
> > +
> > +      mkdir -p /mnt/huge
> > +      mount -t hugetlbfs \
> > +         -o pagesize=2M,size=256M none /mnt/huge
> > +
> > +      write_hugetlbfs_and_get_usage "hugetlb_cgroup_test1" "$size1" \
> > +         "$populate1" "$write1" "/mnt/huge/test1" "$method" "$private" \
> > +         "$expect_failure"
> > +
> > +      hugetlb_difference1=$hugetlb_difference
> > +      reserved_difference1=$reserved_difference
> > +      reservation_failed1=$reservation_failed
> > +      oom_killed1=$oom_killed
> > +
> > +      local cgroup1_hugetlb_usage=$cgroup_path/hugetlb_cgroup_test1/hugetlb.2MB.usage_in_bytes
> > +      local cgroup1_reservation_usage=$cgroup_path/hugetlb_cgroup_test1/hugetlb.2MB.reservation_usage_in_bytes
> > +      local cgroup2_hugetlb_usage=$cgroup_path/hugetlb_cgroup_test2/hugetlb.2MB.usage_in_bytes
> > +      local cgroup2_reservation_usage=$cgroup_path/hugetlb_cgroup_test2/hugetlb.2MB.reservation_usage_in_bytes
> > +
> > +      local usage_before_second_write=$(cat $cgroup1_hugetlb_usage)
> > +      local reservation_usage_before_second_write=$(cat \
> > +         $cgroup1_reservation_usage)
> > +
> > +      write_hugetlbfs_and_get_usage "hugetlb_cgroup_test2" "$size2" \
> > +         "$populate2" "$write2" "/mnt/huge/test2" "$method" "$private" \
> > +         "$expect_failure"
> > +
> > +      hugetlb_difference2=$hugetlb_difference
> > +      reserved_difference2=$reserved_difference
> > +      reservation_failed2=$reservation_failed
> > +      oom_killed2=$oom_killed
> > +
> > +      expect_equal "$usage_before_second_write" \
> > +         "$(cat $cgroup1_hugetlb_usage)" "Usage changed."
> > +      expect_equal "$reservation_usage_before_second_write" \
> > +         "$(cat $cgroup1_reservation_usage)" "Reservation usage changed."
> > +
> > +      cleanup_hugetlb_memory
> > +
> > +      local final_hugetlb=$(cat $cgroup1_hugetlb_usage)
> > +      local final_reservation=$(cat $cgroup1_reservation_usage)
> > +
> > +      expect_equal "0" "$final_hugetlb" \
> > +         "hugetlbt_cgroup_test1 final hugetlb is not zero"
> > +      expect_equal "0" "$final_reservation" \
> > +         "hugetlbt_cgroup_test1 final reservation is not zero"
> > +
> > +      local final_hugetlb=$(cat $cgroup2_hugetlb_usage)
> > +      local final_reservation=$(cat $cgroup2_reservation_usage)
> > +
> > +      expect_equal "0" "$final_hugetlb" \
> > +         "hugetlb_cgroup_test2 final hugetlb is not zero"
> > +      expect_equal "0" "$final_reservation" \
> > +         "hugetlb_cgroup_test2 final reservation is not zero"
> > +}
> > +
> > +for private in "" "-r" ; do
> > +for populate in  "" "-o"; do
> > +for method in 0 1 2; do
> > +
> > +# Skip mmap(MAP_HUGETLB | MAP_SHARED). Doesn't seem to be supported.
> > +if [[ "$method" == 1 ]] && [[ "$private" == "" ]]; then
> > +      continue
> > +fi
> > +
> > +# Skip populated shmem tests. Doesn't seem to be supported.
> > +if [[ "$method" == 2"" ]] && [[ "$populate" == "-o" ]]; then
> > +      continue
> > +fi
> > +
> > +cleanup
> > +echo
> > +echo
> > +echo
> > +echo Test normal case.
> > +echo private=$private, populate=$populate, method=$method
> > +run_test $((10 * 1024 * 1024)) "$populate" "" $((20 * 1024 * 1024)) \
> > +      $((20 * 1024 * 1024)) 10 "$method" "$private" "0"
> > +
> > +echo Memory charged to hugtlb=$hugetlb_difference
> > +echo Memory charged to reservation=$reserved_difference
> > +
> > +if [[ "$populate" == "-o" ]]; then
> > +      expect_equal "$((10 * 1024 * 1024))" "$hugetlb_difference" \
> > +         "Reserved memory charged to hugetlb cgroup."
> > +else
> > +      expect_equal "0" "$hugetlb_difference" \
> > +         "Reserved memory charged to hugetlb cgroup."
> > +fi
> > +
> > +expect_equal "$((10 * 1024 * 1024))" "$reserved_difference" \
> > +      "Reserved memory not charged to reservation usage."
> > +echo 'PASS'
> > +
> > +cleanup
> > +echo
> > +echo
> > +echo
> > +echo Test normal case with write.
> > +echo private=$private, populate=$populate, method=$method
> > +run_test $((10 * 1024 * 1024)) "$populate" '-w' $((20 * 1024 * 1024)) \
> > +      $((20 * 1024 * 1024)) 10 "$method" "$private" "0"
> > +
> > +echo Memory charged to hugtlb=$hugetlb_difference
> > +echo Memory charged to reservation=$reserved_difference
> > +
> > +expect_equal "$((10 * 1024 * 1024))" "$hugetlb_difference" \
> > +      "Reserved memory charged to hugetlb cgroup."
> > +expect_equal "$((10 * 1024 * 1024))" "$reserved_difference" \
> > +      "Reserved memory not charged to reservation usage."
> > +echo 'PASS'
> > +
> > +
> > +cleanup
> > +echo
> > +echo
> > +echo
> > +echo Test more than reservation case.
> > +echo private=$private, populate=$populate, method=$method
> > +run_test "$((10 * 1024 * 1024))" "$populate" '' "$((20 * 1024 * 1024))" \
> > +      "$((5 * 1024 * 1024))" "10" "$method" "$private" "1"
> > +
> > +expect_equal "1" "$reservation_failed" "Reservation succeeded."
> > +echo 'PASS'
> > +
> > +cleanup
> > +
> > +echo
> > +echo
> > +echo
> > +echo Test more than cgroup limit case.
> > +echo private=$private, populate=$populate, method=$method
> > +
> > +# Not sure if shm memory can be cleaned up when the process gets sigbus'd.
> > +if [[ "$method" != 2 ]]; then
> > +      run_test $((10 * 1024 * 1024)) "$populate" "-w" $((5 * 1024 * 1024)) \
> > +         $((20 * 1024 * 1024)) 10 "$method" "$private" "1"
> > +
> > +      expect_equal "1" "$oom_killed" "Not oom killed."
> > +fi
> > +echo 'PASS'
> > +
> > +cleanup
> > +
> > +echo
> > +echo
> > +echo
> > +echo Test normal case, multiple cgroups.
> > +echo private=$private, populate=$populate, method=$method
> > +run_multiple_cgroup_test "$((6 * 1024 * 1024))" "$populate" "" \
> > +      "$((20 * 1024 * 1024))" "$((20 * 1024 * 1024))" "$((10 * 1024 * 1024))" \
> > +      "$populate" "" "$((20 * 1024 * 1024))" "$((20 * 1024 * 1024))" "10" \
> > +      "$method" "$private" "0"
> > +
> > +echo Memory charged to hugtlb1=$hugetlb_difference1
> > +echo Memory charged to reservation1=$reserved_difference1
> > +echo Memory charged to hugtlb2=$hugetlb_difference2
> > +echo Memory charged to reservation2=$reserved_difference2
> > +
> > +expect_equal "$((6 * 1024 * 1024))" "$reserved_difference1" \
> > +      "Incorrect reservations charged to cgroup 1."
> > +expect_equal "$((10 * 1024 * 1024))" "$reserved_difference2" \
> > +      "Incorrect reservation charged to cgroup 2."
> > +if [[ "$populate" == "-o" ]]; then
> > +      expect_equal "$((6 * 1024 * 1024))" "$hugetlb_difference1" \
> > +         "Incorrect hugetlb charged to cgroup 1."
> > +      expect_equal "$((10 * 1024 * 1024))" "$hugetlb_difference2" \
> > +         "Incorrect hugetlb charged to cgroup 2."
> > +else
> > +      expect_equal "0" "$hugetlb_difference1" \
> > +         "Incorrect hugetlb charged to cgroup 1."
> > +      expect_equal "0" "$hugetlb_difference2" \
> > +         "Incorrect hugetlb charged to cgroup 2."
> > +fi
> > +echo 'PASS'
> > +
> > +cleanup
> > +echo
> > +echo
> > +echo
> > +echo Test normal case with write, multiple cgroups.
> > +echo private=$private, populate=$populate, method=$method
> > +run_multiple_cgroup_test "$((6 * 1024 * 1024))" "$populate" "-w" \
> > +      "$((20 * 1024 * 1024))" "$((20 * 1024 * 1024))" "$((10 * 1024 * 1024))" \
> > +      "$populate" "-w" "$((20 * 1024 * 1024))" "$((20 * 1024 * 1024))" "10" \
> > +      "$method" "$private" "0"
> > +
> > +echo Memory charged to hugtlb1=$hugetlb_difference1
> > +echo Memory charged to reservation1=$reserved_difference1
> > +echo Memory charged to hugtlb2=$hugetlb_difference2
> > +echo Memory charged to reservation2=$reserved_difference2
> > +
> > +expect_equal "$((6 * 1024 * 1024))" "$hugetlb_difference1" \
> > +      "Incorrect hugetlb charged to cgroup 1."
> > +expect_equal "$((6 * 1024 * 1024))" "$reserved_difference1" \
> > +      "Incorrect reservation charged to cgroup 1."
> > +expect_equal "$((10 * 1024 * 1024))" "$hugetlb_difference2" \
> > +      "Incorrect hugetlb charged to cgroup 2."
> > +expect_equal "$((10 * 1024 * 1024))" "$reserved_difference2" \
> > +      "Incorrected reservation charged to cgroup 2."
> > +
> > +echo 'PASS'
> > +
> > +done # private
> > +done # populate
> > +done # method
> > +
> > +umount $cgroup_path
> > +rmdir $cgroup_path
> > diff --git a/tools/testing/selftests/vm/write_hugetlb_memory.sh b/tools/testing/selftests/vm/write_hugetlb_memory.sh
> > new file mode 100644
> > index 0000000000000..08f5fa5527cfd
> > --- /dev/null
> > +++ b/tools/testing/selftests/vm/write_hugetlb_memory.sh
> > @@ -0,0 +1,22 @@
> > +#!/bin/sh
> > +# SPDX-License-Identifier: GPL-2.0
> > +
> > +set -e
> > +
> > +size=$1
> > +populate=$2
> > +write=$3
> > +cgroup=$4
> > +path=$5
> > +method=$6
> > +private=$7
> > +want_sleep=$8
> > +
> > +echo "Putting task in cgroup '$cgroup'"
> > +echo $$ > /dev/cgroup/memory/"$cgroup"/tasks
> > +
> > +echo "Method is $method"
> > +
> > +set +e
> > +./write_to_hugetlbfs -p "$path" -s "$size" "$write" "$populate" -m "$method" \
> > +      "$private" "$want_sleep"
> > diff --git a/tools/testing/selftests/vm/write_to_hugetlbfs.c b/tools/testing/selftests/vm/write_to_hugetlbfs.c
> > new file mode 100644
> > index 0000000000000..f02a897427a97
> > --- /dev/null
> > +++ b/tools/testing/selftests/vm/write_to_hugetlbfs.c
> > @@ -0,0 +1,252 @@
> > +// SPDX-License-Identifier: GPL-2.0
> > +/*
> > + * This program reserves and uses hugetlb memory, supporting a bunch of
> > + * scenorios needed by the charged_reserved_hugetlb.sh test.
>
> Spelling?
>
> > + */
> > +
> > +#include <err.h>
> > +#include <errno.h>
> > +#include <signal.h>
> > +#include <stdio.h>
> > +#include <stdlib.h>
> > +#include <string.h>
> > +#include <unistd.h>
> > +#include <fcntl.h>
> > +#include <sys/types.h>
> > +#include <sys/shm.h>
> > +#include <sys/stat.h>
> > +#include <sys/mman.h>
> > +
> > +/* Global definitions. */
> > +enum method {
> > +     HUGETLBFS,
> > +     MMAP_MAP_HUGETLB,
> > +     SHM,
> > +     MAX_METHOD
> > +};
> > +
> > +
> > +/* Global variables. */
> > +static const char *self;
> > +static char *shmaddr;
> > +static int shmid;
> > +
> > +/*
> > + * Show usage and exit.
> > + */
> > +static void exit_usage(void)
> > +{
> > +
> > +     printf("Usage: %s -p <path to hugetlbfs file> -s <size to map> "
> > +             "[-m <0=hugetlbfs | 1=mmap(MAP_HUGETLB)>] [-l] [-r] "
> > +             "[-o] [-w]\n", self);
> > +     exit(EXIT_FAILURE);
> > +}
> > +
> > +void sig_handler(int signo)
> > +{
> > +     printf("Received %d.\n", signo);
> > +     if (signo == SIGINT) {
> > +             printf("Deleting the memory\n");
> > +             if (shmdt((const void *)shmaddr) != 0) {
> > +                     perror("Detach failure");
> > +                     shmctl(shmid, IPC_RMID, NULL);
> > +                     exit(4);
>
> Is this a skip error code? Please note that kselftest framework
> interprets this as a skipped test when returb value is 4.
>
This is not a kselftest framework binary. It's a tool to be called
from charge_reserved_hugetlb.sh The exit value is just to make all the
exits in this file return different codes so I can debug easier where
the tool exited from. They don't actually mean anything. Is that OK?

> > +             }
> > +
> > +             shmctl(shmid, IPC_RMID, NULL);
> > +             printf("Done deleting the memory\n");
> > +     }
> > +     exit(2);
>
> What about this one? What does exit code 2 mean?
>
> > +}
> > +
> > +int main(int argc, char **argv)
> > +{
> > +     int fd = 0;
> > +     int key = 0;
> > +     int *ptr = NULL;
> > +     int c = 0;
> > +     int size = 0;
> > +     char path[256] = "";
> > +     enum method method = MAX_METHOD;
> > +     int want_sleep = 0, private = 0;
> > +     int populate = 0;
> > +     int write = 0;
> > +
> > +     unsigned long i;
> > +
> > +
> > +     if (signal(SIGINT, sig_handler) == SIG_ERR)
> > +             err(1, "\ncan't catch SIGINT\n");
> > +
> > +     /* Parse command-line arguments. */
> > +     setvbuf(stdout, NULL, _IONBF, 0);
> > +     self = argv[0];
> > +
> > +     while ((c = getopt(argc, argv, "s:p:m:owlr")) != -1) {
> > +             switch (c) {
> > +             case 's':
> > +                     size = atoi(optarg);
> > +                     break;
> > +             case 'p':
> > +                     strncpy(path, optarg, sizeof(path));
> > +                     break;
> > +             case 'm':
> > +                     if (atoi(optarg) >= MAX_METHOD) {
> > +                             errno = EINVAL;
> > +                             perror("Invalid -m.");
> > +                             exit_usage();
> > +                     }
> > +                     method = atoi(optarg);
> > +                     break;
> > +             case 'o':
> > +                     populate = 1;
> > +                     break;
> > +             case 'w':
> > +                     write = 1;
> > +                     break;
> > +             case 'l':
> > +                     want_sleep = 1;
> > +                     break;
> > +             case 'r':
> > +                     private = 1;
> > +                     break;
> > +             default:
> > +                     errno = EINVAL;
> > +                     perror("Invalid arg");
> > +                     exit_usage();
> > +             }
> > +     }
> > +
> > +     if (strncmp(path, "", sizeof(path)) != 0) {
> > +             printf("Writing to this path: %s\n", path);
> > +     } else {
> > +             errno = EINVAL;
> > +             perror("path not found");
> > +             exit_usage();
> > +     }
> > +
> > +     if (size != 0) {
> > +             printf("Writing this size: %d\n", size);
> > +     } else {
> > +             errno = EINVAL;
> > +             perror("size not found");
> > +             exit_usage();
> > +     }
> > +
> > +     if (!populate)
> > +             printf("Not populating.\n");
> > +     else
> > +             printf("Populating.\n");
> > +
> > +     if (!write)
> > +             printf("Not writing to memory.\n");
> > +
> > +     if (method == MAX_METHOD) {
> > +             errno = EINVAL;
> > +             perror("-m Invalid");
> > +             exit_usage();
> > +     } else
> > +             printf("Using method=%d\n", method);
> > +
> > +     if (!private)
> > +             printf("Shared mapping.\n");
> > +     else
> > +             printf("Private mapping.\n");
> > +
> > +
> > +     switch (method) {
> > +     case HUGETLBFS:
> > +             printf("Allocating using HUGETLBFS.\n");
> > +             fd = open(path, O_CREAT | O_RDWR, 0777);
> > +             if (fd == -1)
> > +                     err(1, "Failed to open file.");
> > +
> > +             ptr = mmap(NULL, size, PROT_READ | PROT_WRITE,
> > +                     (private ? MAP_PRIVATE : MAP_SHARED) | (populate ?
> > +                             MAP_POPULATE : 0), fd, 0);
> > +
> > +             if (ptr == MAP_FAILED) {
> > +                     close(fd);
> > +                     err(1, "Error mapping the file");
> > +             }
> > +             break;
> > +     case MMAP_MAP_HUGETLB:
> > +             printf("Allocating using MAP_HUGETLB.\n");
> > +             ptr = mmap(NULL, size,
> > +             PROT_READ | PROT_WRITE,
> > +             (private ? (MAP_PRIVATE | MAP_ANONYMOUS) : MAP_SHARED) |
> > +             MAP_HUGETLB | (populate ?
> > +                     MAP_POPULATE : 0),
> > +             -1, 0);
> > +
> > +             if (ptr == MAP_FAILED)
> > +                     err(1, "mmap");
> > +
> > +             printf("Returned address is %p\n", ptr);
> > +             break;
> > +     case SHM:
> > +             printf("Allocating using SHM.\n");
> > +             shmid = shmget(key, size, SHM_HUGETLB | IPC_CREAT | SHM_R |
> > +                             SHM_W);
> > +             if (shmid < 0) {
> > +                     shmid = shmget(++key, size, SHM_HUGETLB | IPC_CREAT |
> > +                                     SHM_R | SHM_W);
> > +                     if (shmid < 0)
> > +                             err(1, "shmget");
> > +
> > +             }
> > +             printf("shmid: 0x%x, shmget key:%d\n", shmid, key);
> > +
> > +             shmaddr = shmat(shmid, NULL, 0);
> > +             if (shmaddr == (char *)-1) {
> > +                     perror("Shared memory attach failure");
> > +                     shmctl(shmid, IPC_RMID, NULL);
> > +                     exit(2);
> > +             }
> > +             printf("shmaddr: %p\n", shmaddr);
> > +
> > +             break;
> > +     default:
> > +             errno = EINVAL;
> > +             err(1, "Invalid method.");
> > +     }
> > +
> > +     if (write) {
> > +             printf("Writing to memory.\n");
> > +             if (method != SHM) {
> > +                     memset(ptr, 1, size);
> > +             } else {
> > +                     printf("Starting the writes:\n");
> > +                     for (i = 0; i < size; i++) {
> > +                             shmaddr[i] = (char)(i);
> > +                             if (!(i % (1024 * 1024)))
> > +                                     printf(".");
> > +                     }
> > +                     printf("\n");
> > +
> > +                     printf("Starting the Check...");
> > +                     for (i = 0; i < size; i++)
> > +                             if (shmaddr[i] != (char)i) {
> > +                                     printf("\nIndex %lu mismatched\n", i);
> > +                                     exit(3);
> > +                             }
> > +                     printf("Done.\n");
> > +
> > +
> > +             }
> > +     }
> > +
> > +     if (want_sleep) {
> > +             /* Signal to caller that we're done. */
> > +             printf("DONE\n");
> > +
> > +             /* Hold memory until external kill signal is delivered. */
> > +             while (1)
> > +                     sleep(100);
>
> Please don't add sleeps. This will hold up the kselftest run.

This tool is meant to allocate a bunch of memory and hold it until the
code in ./charge_reserved_hugetlb.sh checks that the usage is
accounted for. charge_reserved_hugetlb.sh runs this tool in the
background, and asks it to hold the memory until it verifies
accounting, then asks it to delete the memory. It should not hold up a
run.

>
> > +     }
> > +
> > +     close(fd);
>
> Is this close() necessary in all cases? Looks like MMAP_MAP_HUGETLB
> is the only case that opens it.
>
> I am not sure if the error legs are correct.
>
> > +
> > +     return 0;
> > +}
> > --
> > 2.23.0.162.g0b9fbb3734-goog
> >
>
> thanks,
> -- Shuah

Thanks for the review, I should be able to address everything else in
the next patchset.

