Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92FF1C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 16:56:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 580BF21848
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 16:56:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 580BF21848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7FE08E0003; Tue, 26 Feb 2019 11:56:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2EB08E0001; Tue, 26 Feb 2019 11:56:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF8518E0003; Tue, 26 Feb 2019 11:56:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7364F8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 11:56:31 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id 29so5615445eds.12
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 08:56:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=pornVtbyKIbWqI1koki/+0z5t+kHpkI0e9fc9FWPllQ=;
        b=knDDHgh/x6j1qPwSAaBEkbPcC2JvWUWDC97gUg0B/WoSjK5CPE8rGHW/qkn4+GXDpW
         AFq3JBdqtsGlFPiyGj0rPQu3c06TUN+GAqGhLZPrga5tqkbcQYc1RtLg9Q+s7dhln0u+
         +2X4Qs53dkLay0KxLOP415nEnnBrsnZPwIhA6bOTxWpI/DQzbh9xDK4sEEZkJt4GrJ60
         Lr8g74vJWsBrOx3H0bWiZBRrNy5J9zbQ+DoadTBQXSztZYXzF7l/UjXllEHXRkrRnQjM
         4K+5UwJmhBMQjYzsSnDI4LnBhreT3WKhOKNl1maLKjQMuwRwO3h5MZf7r0dLmhSrCvmX
         3A4A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AHQUAub8GXd2h1Be2tWSSfh77prp/zPOraz0JoL+MCHBo0J75HDoIPQ8
	t8E81Qh/mDxksgQtELR0BNNeJznChmeeFOL8eTz1IH5hJWL5OksFyW6F5EOsTNjYhYv2tAJVyDH
	JzEjFcAizKx/pd4qdqhCdpw7jCtTOoWT7d4yGJhmNoYnTqcN4VvF/z4kRSYlF//AcYQ==
X-Received: by 2002:a50:9235:: with SMTP id i50mr4991257eda.20.1551200190962;
        Tue, 26 Feb 2019 08:56:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY1YWVbVX/ZWuCGyZeDbC9sEsRDjQoIh2yKYkK76CmiqYvR94pKhJiSKyTWgbhoMuCR+TTc
X-Received: by 2002:a50:9235:: with SMTP id i50mr4991210eda.20.1551200189954;
        Tue, 26 Feb 2019 08:56:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551200189; cv=none;
        d=google.com; s=arc-20160816;
        b=nKCga2KnyFSF8o0zvQkt8bJD7sXVsdJ3tQxChlKNImwyHXcGHvQNy+8BiNZm5japGL
         yWWUniLXkVRqjW3U+NXjayZoGzBmzCXWaLBvIpunDcR2S6o6Fjwumei/sKApXDS5mCrc
         B8YIWzNktSc0kVK3vWJYHlp/IeTnfkYZaWbUkKvnJt+m/KMatRmYvO1CsrbyPREn8l6m
         iIlalOX5fUcKEcn8cEu5hFhNrzcU5//e4CpgbcEtQIC2yDVo4iyVhriox4UH2YIjPxQi
         KkFdRxDztQ7YHRlvHMZxEKPuzgoLNUKOwSrDKMTgsncPsOy5CpUCKTZKd5nKzW1NQYFr
         QRUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=pornVtbyKIbWqI1koki/+0z5t+kHpkI0e9fc9FWPllQ=;
        b=zCNM1HwcqFdyFEPgQsjkV6tvdgtedJQvCgxjijf2XE9WnEEtq5y2T0r/AIv0oN6XMO
         eZWsX/uP7DUwPvwnJ7HEgB9po8bfmRYffPNnV4NHYnhMe0ykdIMKOapOD4LcHkRTVG7K
         +Qlt+HGZyCg+CK9zfvLX4pnz7deqbwlSqRQWsLtHLhNgR0fyLY/yXlvj3mQSRo4zQSp6
         ezjkeysCIDV6eI/d58iTnRK+Qfua7e3//PEaBI/hX2jldzem8QVEaHFAnJClWEhlk6h9
         8wRfMpWwfe+pCr6nqh24qmsnWoug1r5RGrx7DfpOFaAsCNBWGpkyxi5ZuXJejTf4C03Y
         4ccA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d14si2581175ede.302.2019.02.26.08.56.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 08:56:29 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 13240ADC6;
	Tue, 26 Feb 2019 16:56:29 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 9E2AF1E4255; Tue, 26 Feb 2019 17:56:28 +0100 (CET)
Date: Tue, 26 Feb 2019 17:56:28 +0100
From: Jan Kara <jack@suse.cz>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, mgorman@suse.de
Subject: Truncate regression due to commit 69b6c1319b6
Message-ID: <20190226165628.GB24711@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="f2QGlHpHGjS2mn6Y"
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--f2QGlHpHGjS2mn6Y
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello Matthew,

after some peripeties, I was able to bisect down to a regression in
truncate performance caused by commit 69b6c1319b6 "mm: Convert truncate to
XArray". The initial benchmark that indicated the regression was a bonnie++
file delete test (some 4-5% regression). It is however much easier (and
faster!) to see the regression with the attached benchmark. With it I can
see about 10% regression on my test machine: Average of 10 runs, time in us.

COMMIT      AVG            STDDEV
a97e7904c0  1431256.500000 1489.361759
69b6c1319b  1566944.000000 2252.692877

The benchmark has to be run so that the total file size is about 2x the
memory size (as the regression seems to be in trucating existing workingset
entries). So on my test machine with 32 GB of RAM I run it like:

# This prepares the environment
mkfs.xfs -f /dev/sdb1
mount -t xfs /dev/sdb1 /mnt
./trunc-bench /mnt/file 64 1
# This does the truncation
./trunc-bench /mnt/file 64 2

I've gathered also perf profiles but from the first look they don't show
anything surprising besides xas_load() and xas_store() taking up more time
than original counterparts did. I'll try to dig more into this but any idea
is appreciated.

My test machine is 8 CPU Intel(R) Xeon(R) CPU E3-1240 v5 @ 3.50GHz.

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--f2QGlHpHGjS2mn6Y
Content-Type: text/x-c; charset=us-ascii
Content-Disposition: attachment; filename="trunc-bench.c"

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/time.h>

#define COUNT 1024
#define BUFSIZE (1024*1024)

char *buf;

void read_file(int fd)
{
	int i;

	if (ftruncate(fd, BUFSIZE*COUNT) < 0) {
		perror("truncate");
		exit(1);
	}
	for (i = 0; i < COUNT; i++) {
		if (read(fd, buf, BUFSIZE) != BUFSIZE) {
			perror("read");
			exit(1);
		}
	}
}

int main(int argc, char **argv)
{
	int fd;
	int fcount, i, stages;
	char fname[128];
	struct timeval start, end;

	if (argc != 4) {
		fprintf(stderr, "Usage: trunc-bench <file> <file-count> <stages>\n");
		return 1;
	}
	fcount = strtol(argv[2], NULL, 0);
	stages = strtol(argv[3], NULL, 0);
	buf = malloc(BUFSIZE);
	if (!buf) {
		fprintf(stderr, "Cannot allocate write buffer.\n");
		return 1;
	}
	memset(buf, 'a', BUFSIZE);
	
	if (stages & 1) {
		fprintf(stderr, "Creating files...\n");
		for (i = 0; i < fcount; i++ ) {
			sprintf(fname, "%s%d", argv[1], i);
			fd = open(fname, O_RDWR | O_TRUNC | O_CREAT, 0644);
			if (fd < 0) {
				perror("open");
				return 1;
			}
			read_file(fd);
			close(fd);
		}
	}
	if (stages & 2) {
		fprintf(stderr, "Removing files...\n");
		gettimeofday(&start, NULL);
		for (i = 0; i < fcount; i++ ) {
			sprintf(fname, "%s%d", argv[1], i);
			truncate(fname, 0);
		}
		gettimeofday(&end, NULL);
		printf("%lu us\n", (end.tv_sec - start.tv_sec) * 1000000UL + (end.tv_usec - start.tv_usec));
	}
	fprintf(stderr, "Done.\n");

	return 0;
}

--f2QGlHpHGjS2mn6Y--

