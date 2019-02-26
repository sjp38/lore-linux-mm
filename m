Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAC93C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 06:50:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 823BE213A2
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 06:50:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 823BE213A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 219F08E0002; Tue, 26 Feb 2019 01:50:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CA7E8E0004; Tue, 26 Feb 2019 01:50:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C5198E0002; Tue, 26 Feb 2019 01:50:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id D31748E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 01:50:45 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id z22so9739364iog.5
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 22:50:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=5hIKqkzIXsxkF8udtGIyRHxwK0fkgaeAkIRrb/6h2l4=;
        b=aW8GTMIwgRYNPXpd2ys0peBqQ9mQcb3vet9G3bwRyaR/0o6wlD6RJntMTpxck7t+GL
         XmSMHkweqVyFVZoPczPxyg87nOcUTyORtjIvj/exSKyGnRsd7sXVZPUt8HGeSZTEQA52
         3ukTvyndwH5cbirSD8RH+QL69mwDdRPgyeL4pLkG68cJr94Woy8UMnis0D1/ZkdFlfBS
         waaxNwJ2DNxwLiwPSTX4+TE/rp2Mib8mUS5ne9ko/45TtChIqDX95zT4luaIZvrCsaMX
         /DLTDKYS+SDRZSOBWTcGfsIecL/R18Wfcft2LdcGyLNv/KoTjjMflUp3/3HK9JWKQRa0
         g8kg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuZtnaTPwsdmp4mbhfInUGp8QYmOKuwEyzl2j4HMMPhQPRyn+zBz
	6sFM3ToSds1obmHvt/4RrGmmBerglziqi01+o+KLaYR6Vx1IFkkrR1GKdV4863GAl8AquMk28Px
	D0ynCOeoEzRDaqBYcIgirm0ug8iylHKBqBoAvg7sakrSzjCtkZx8y00YVJCDKmyGv4w==
X-Received: by 2002:a24:6fce:: with SMTP id x197mr351378itb.108.1551163845605;
        Mon, 25 Feb 2019 22:50:45 -0800 (PST)
X-Google-Smtp-Source: APXvYqyt/2+JZO4bVTxvwwacF/RzS2IDi9TRADxhCgszA+ScapJKl3yK7VDJV30OwCQS0pljk2xz
X-Received: by 2002:a24:6fce:: with SMTP id x197mr351345itb.108.1551163844482;
        Mon, 25 Feb 2019 22:50:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551163844; cv=none;
        d=google.com; s=arc-20160816;
        b=B2MquDemtkmO7gZt186eeOCsq4PcuwWpRB/3865L+5iUU5b0S2VXkqhPycS64nvrW0
         3pWyHXkX6IMNIHroszAK0zSC3qfIBE4G4smJNNEc9WrrzY0F0WTEfSB1Hhy0PtYKStf9
         2KLMphwnttgXAYEGPqRrt1C1/OkeG0P+Olu6h9kxFda5/zwgzcZ3lAceGdF7hdNYYKp7
         /tplGCDbCpuZZCRKUW2DkzQ5zSqF79qtOxsJIu/BZ6+Lv5jxKSxmNalIZoBVROVZRXk1
         6+bjK5cR6U2kSUC1YIqFDJ3qfMhqEM68tRhXbxZzAa/zhZ1tNrW5S55XxtEWWjP3N/cj
         ubyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=5hIKqkzIXsxkF8udtGIyRHxwK0fkgaeAkIRrb/6h2l4=;
        b=RevdeaX2aKVrM9OLSkivsQxMuFRNcAz+CHGMJLSEXPmm6mBULaNp5e5xXurhNFnqvK
         DObU+Adsx/v+WhmRoHnqOH9rY3xOY57cL/bdU1dehYdqRyJlq+j6Rj1w0Y1GVY9Kx7W0
         Pg0DIowSxU2ymy2+crkdcAZhGlwTfn5ixC59orIeHSvqnMOZKq0oO6JGLVM6LSAoXEzH
         Qe/IcP8MT6Ji1xp/E2ZAcPJTnbCHr9RF0eMPMbgVJorT5L9Pwlrd7y/Jy7rWzSKGW7zt
         9TObXSTdUkF5SvRBeolzMgMlz9GGVN43qNBVrBh0dgw6NY4RmnboElQn5BP2UQSlN2jy
         1C0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i33si5527902jaf.85.2019.02.25.22.50.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 22:50:44 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1Q6haXf042590
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 01:50:43 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qvyr028gx-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 01:50:43 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 26 Feb 2019 06:50:41 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 26 Feb 2019 06:50:36 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1Q6oa1d34406624
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 26 Feb 2019 06:50:36 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E7E2511C052;
	Tue, 26 Feb 2019 06:50:35 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 888F911C054;
	Tue, 26 Feb 2019 06:50:34 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 26 Feb 2019 06:50:34 +0000 (GMT)
Date: Tue, 26 Feb 2019 08:50:32 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        David Hildenbrand <david@redhat.com>, Hugh Dickins <hughd@google.com>,
        Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>,
        Pavel Emelyanov <xemul@virtuozzo.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
        Marty McFadden <mcfadden8@llnl.gov>,
        Andrea Arcangeli <aarcange@redhat.com>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        Denis Plotnikov <dplotnikov@virtuozzo.com>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>,
        "Kirill A . Shutemov" <kirill@shutemov.name>,
        "Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 25/26] userfaultfd: selftests: refactor statistics
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-26-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212025632.28946-26-peterx@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022606-0008-0000-0000-000002C4F493
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022606-0009-0000-0000-000022313C59
Message-Id: <20190226065032.GC5873@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-26_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902260051
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:31AM +0800, Peter Xu wrote:
> Introduce uffd_stats structure for statistics of the self test, at the
> same time refactor the code to always pass in the uffd_stats for either
> read() or poll() typed fault handling threads instead of using two
> different ways to return the statistic results.  No functional change.
> 
> With the new structure, it's very easy to introduce new statistics.
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  tools/testing/selftests/vm/userfaultfd.c | 76 +++++++++++++++---------
>  1 file changed, 49 insertions(+), 27 deletions(-)
> 
> diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
> index 5d1db824f73a..e5d12c209e09 100644
> --- a/tools/testing/selftests/vm/userfaultfd.c
> +++ b/tools/testing/selftests/vm/userfaultfd.c
> @@ -88,6 +88,12 @@ static char *area_src, *area_src_alias, *area_dst, *area_dst_alias;
>  static char *zeropage;
>  pthread_attr_t attr;
> 
> +/* Userfaultfd test statistics */
> +struct uffd_stats {
> +	int cpu;
> +	unsigned long missing_faults;
> +};
> +
>  /* pthread_mutex_t starts at page offset 0 */
>  #define area_mutex(___area, ___nr)					\
>  	((pthread_mutex_t *) ((___area) + (___nr)*page_size))
> @@ -127,6 +133,17 @@ static void usage(void)
>  	exit(1);
>  }
> 
> +static void uffd_stats_reset(struct uffd_stats *uffd_stats,
> +			     unsigned long n_cpus)
> +{
> +	int i;
> +
> +	for (i = 0; i < n_cpus; i++) {
> +		uffd_stats[i].cpu = i;
> +		uffd_stats[i].missing_faults = 0;
> +	}
> +}
> +
>  static int anon_release_pages(char *rel_area)
>  {
>  	int ret = 0;
> @@ -469,8 +486,8 @@ static int uffd_read_msg(int ufd, struct uffd_msg *msg)
>  	return 0;
>  }
> 
> -/* Return 1 if page fault handled by us; otherwise 0 */
> -static int uffd_handle_page_fault(struct uffd_msg *msg)
> +static void uffd_handle_page_fault(struct uffd_msg *msg,
> +				   struct uffd_stats *stats)
>  {
>  	unsigned long offset;
> 
> @@ -485,18 +502,19 @@ static int uffd_handle_page_fault(struct uffd_msg *msg)
>  	offset = (char *)(unsigned long)msg->arg.pagefault.address - area_dst;
>  	offset &= ~(page_size-1);
> 
> -	return copy_page(uffd, offset);
> +	if (copy_page(uffd, offset))
> +		stats->missing_faults++;
>  }
> 
>  static void *uffd_poll_thread(void *arg)
>  {
> -	unsigned long cpu = (unsigned long) arg;
> +	struct uffd_stats *stats = (struct uffd_stats *)arg;
> +	unsigned long cpu = stats->cpu;
>  	struct pollfd pollfd[2];
>  	struct uffd_msg msg;
>  	struct uffdio_register uffd_reg;
>  	int ret;
>  	char tmp_chr;
> -	unsigned long userfaults = 0;
> 
>  	pollfd[0].fd = uffd;
>  	pollfd[0].events = POLLIN;
> @@ -526,7 +544,7 @@ static void *uffd_poll_thread(void *arg)
>  				msg.event), exit(1);
>  			break;
>  		case UFFD_EVENT_PAGEFAULT:
> -			userfaults += uffd_handle_page_fault(&msg);
> +			uffd_handle_page_fault(&msg, stats);
>  			break;
>  		case UFFD_EVENT_FORK:
>  			close(uffd);
> @@ -545,28 +563,27 @@ static void *uffd_poll_thread(void *arg)
>  			break;
>  		}
>  	}
> -	return (void *)userfaults;
> +
> +	return NULL;
>  }
> 
>  pthread_mutex_t uffd_read_mutex = PTHREAD_MUTEX_INITIALIZER;
> 
>  static void *uffd_read_thread(void *arg)
>  {
> -	unsigned long *this_cpu_userfaults;
> +	struct uffd_stats *stats = (struct uffd_stats *)arg;
>  	struct uffd_msg msg;
> 
> -	this_cpu_userfaults = (unsigned long *) arg;
> -	*this_cpu_userfaults = 0;
> -
>  	pthread_mutex_unlock(&uffd_read_mutex);
>  	/* from here cancellation is ok */
> 
>  	for (;;) {
>  		if (uffd_read_msg(uffd, &msg))
>  			continue;
> -		(*this_cpu_userfaults) += uffd_handle_page_fault(&msg);
> +		uffd_handle_page_fault(&msg, stats);
>  	}
> -	return (void *)NULL;
> +
> +	return NULL;
>  }
> 
>  static void *background_thread(void *arg)
> @@ -582,13 +599,12 @@ static void *background_thread(void *arg)
>  	return NULL;
>  }
> 
> -static int stress(unsigned long *userfaults)
> +static int stress(struct uffd_stats *uffd_stats)
>  {
>  	unsigned long cpu;
>  	pthread_t locking_threads[nr_cpus];
>  	pthread_t uffd_threads[nr_cpus];
>  	pthread_t background_threads[nr_cpus];
> -	void **_userfaults = (void **) userfaults;
> 
>  	finished = 0;
>  	for (cpu = 0; cpu < nr_cpus; cpu++) {
> @@ -597,12 +613,13 @@ static int stress(unsigned long *userfaults)
>  			return 1;
>  		if (bounces & BOUNCE_POLL) {
>  			if (pthread_create(&uffd_threads[cpu], &attr,
> -					   uffd_poll_thread, (void *)cpu))
> +					   uffd_poll_thread,
> +					   (void *)&uffd_stats[cpu]))
>  				return 1;
>  		} else {
>  			if (pthread_create(&uffd_threads[cpu], &attr,
>  					   uffd_read_thread,
> -					   &_userfaults[cpu]))
> +					   (void *)&uffd_stats[cpu]))
>  				return 1;
>  			pthread_mutex_lock(&uffd_read_mutex);
>  		}
> @@ -639,7 +656,8 @@ static int stress(unsigned long *userfaults)
>  				fprintf(stderr, "pipefd write error\n");
>  				return 1;
>  			}
> -			if (pthread_join(uffd_threads[cpu], &_userfaults[cpu]))
> +			if (pthread_join(uffd_threads[cpu],
> +					 (void *)&uffd_stats[cpu]))
>  				return 1;
>  		} else {
>  			if (pthread_cancel(uffd_threads[cpu]))
> @@ -910,11 +928,11 @@ static int userfaultfd_events_test(void)
>  {
>  	struct uffdio_register uffdio_register;
>  	unsigned long expected_ioctls;
> -	unsigned long userfaults;
>  	pthread_t uffd_mon;
>  	int err, features;
>  	pid_t pid;
>  	char c;
> +	struct uffd_stats stats = { 0 };
> 
>  	printf("testing events (fork, remap, remove): ");
>  	fflush(stdout);
> @@ -941,7 +959,7 @@ static int userfaultfd_events_test(void)
>  			"unexpected missing ioctl for anon memory\n"),
>  			exit(1);
> 
> -	if (pthread_create(&uffd_mon, &attr, uffd_poll_thread, NULL))
> +	if (pthread_create(&uffd_mon, &attr, uffd_poll_thread, &stats))
>  		perror("uffd_poll_thread create"), exit(1);
> 
>  	pid = fork();
> @@ -957,13 +975,13 @@ static int userfaultfd_events_test(void)
> 
>  	if (write(pipefd[1], &c, sizeof(c)) != sizeof(c))
>  		perror("pipe write"), exit(1);
> -	if (pthread_join(uffd_mon, (void **)&userfaults))
> +	if (pthread_join(uffd_mon, NULL))
>  		return 1;
> 
>  	close(uffd);
> -	printf("userfaults: %ld\n", userfaults);
> +	printf("userfaults: %ld\n", stats.missing_faults);
> 
> -	return userfaults != nr_pages;
> +	return stats.missing_faults != nr_pages;
>  }
> 
>  static int userfaultfd_sig_test(void)
> @@ -975,6 +993,7 @@ static int userfaultfd_sig_test(void)
>  	int err, features;
>  	pid_t pid;
>  	char c;
> +	struct uffd_stats stats = { 0 };
> 
>  	printf("testing signal delivery: ");
>  	fflush(stdout);
> @@ -1006,7 +1025,7 @@ static int userfaultfd_sig_test(void)
>  	if (uffd_test_ops->release_pages(area_dst))
>  		return 1;
> 
> -	if (pthread_create(&uffd_mon, &attr, uffd_poll_thread, NULL))
> +	if (pthread_create(&uffd_mon, &attr, uffd_poll_thread, &stats))
>  		perror("uffd_poll_thread create"), exit(1);
> 
>  	pid = fork();
> @@ -1032,6 +1051,7 @@ static int userfaultfd_sig_test(void)
>  	close(uffd);
>  	return userfaults != 0;
>  }
> +
>  static int userfaultfd_stress(void)
>  {
>  	void *area;
> @@ -1040,7 +1060,7 @@ static int userfaultfd_stress(void)
>  	struct uffdio_register uffdio_register;
>  	unsigned long cpu;
>  	int err;
> -	unsigned long userfaults[nr_cpus];
> +	struct uffd_stats uffd_stats[nr_cpus];
> 
>  	uffd_test_ops->allocate_area((void **)&area_src);
>  	if (!area_src)
> @@ -1169,8 +1189,10 @@ static int userfaultfd_stress(void)
>  		if (uffd_test_ops->release_pages(area_dst))
>  			return 1;
> 
> +		uffd_stats_reset(uffd_stats, nr_cpus);
> +
>  		/* bounce pass */
> -		if (stress(userfaults))
> +		if (stress(uffd_stats))
>  			return 1;
> 
>  		/* unregister */
> @@ -1213,7 +1235,7 @@ static int userfaultfd_stress(void)
> 
>  		printf("userfaults:");
>  		for (cpu = 0; cpu < nr_cpus; cpu++)
> -			printf(" %lu", userfaults[cpu]);
> +			printf(" %lu", uffd_stats[cpu].missing_faults);
>  		printf("\n");
>  	}
> 
> -- 
> 2.17.1
> 

-- 
Sincerely yours,
Mike.

