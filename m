Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D610BC76195
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 16:32:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9AB7E21848
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 16:32:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9AB7E21848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30E826B0003; Wed, 17 Jul 2019 12:32:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 298676B0006; Wed, 17 Jul 2019 12:32:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1620E8E0001; Wed, 17 Jul 2019 12:32:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B77F6B0003
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 12:32:03 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id e14so5423446ljj.3
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 09:32:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:reply-to:to
         :from:subject:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:content-language:content-transfer-encoding;
        bh=E75NjAXiWhvCZvdE/u04pYeja5zqL3MqVrXHa7H4HfY=;
        b=pyzMSLU1gf84V+uQShb2lQZ4SOwXJT3HtLb/5TvDn3KMiRMOJ8e4InhoAU7VOyJW7R
         Rw8Wi7r0q/FpTYKeOVYaESgr5GGsEolh6A6C07i49CgK2Ra0URbjxUOUmf0OgIkaHBrq
         sZ85EuYZtMkGxWG2FRY0QUFaD0rzkTe1ckFAm0khQ7ajhJ9dhgsSHeI9CAteiJ5lLSag
         JiqfdLQn8iIkWe+63QlWxw0XK89oFX1NScnbCoRCfImRhZXjp5T6sgWFuF+0jZu8uALR
         39N8n4v0DFFQtxoDjvJXFkq5b6rgjEbt+xHbsR4/Jz1k9THfigeVSzHN226jp6dC2Ibq
         ewBQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of a13xp0p0v88@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=a13xp0p0v88@gmail.com
X-Gm-Message-State: APjAAAWOQVFuyo1z4uFBJXwtIjwDkIBtJ7n4eH+53Iq57duezMx2Uza7
	5z5+6+SFJmGAZO/aDejNa00Uf3JTdPRohoog+pgaGxYjQEVtwLqjuuqS/Fgg9H2Fr46QpZrv4A0
	4jLdl65Y23TWTdZ2CMe9PW+yfx0AfsT8F2G3OXk4upyfx88jN+EruEnyooGW7940=
X-Received: by 2002:a2e:864d:: with SMTP id i13mr15386468ljj.92.1563381122929;
        Wed, 17 Jul 2019 09:32:02 -0700 (PDT)
X-Received: by 2002:a2e:864d:: with SMTP id i13mr15386418ljj.92.1563381121728;
        Wed, 17 Jul 2019 09:32:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563381121; cv=none;
        d=google.com; s=arc-20160816;
        b=Yb+7FHHqVsL/A7y4tfvQq0cyPUOGuxxdSvAKrDSGLOMobvkA0BfJlWUKZLItNpqgs2
         5PIvuPEd90O8ZrtohpXTRKIm9RX0x7/I0LnQKQA+WxEhN+XskSXZ7VH0i8HJZixQemuS
         yiRkIzEIQ4Ls+CRcmLeD+hlpOgOcGv1Um6iPo18J0qGjKRzi/y492K7qFoCEgdy1DvzJ
         mmM/8EmNa/3SztcxzzlQccYTzVlz7b7C1a7mbj+UQtdWIWdwFzH/8Q0KRJmDmzqWGtxl
         tx6auIkeRSHBh7Lkm4OgrYhazUF5yEGZKgm4W/JbdvXimhUmxeIFRsQHwO/7bz5Zh7//
         pvGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:mime-version:user-agent
         :date:message-id:autocrypt:openpgp:subject:from:to:reply-to;
        bh=E75NjAXiWhvCZvdE/u04pYeja5zqL3MqVrXHa7H4HfY=;
        b=EakDghmUoruSF7brKLcOgJguwdfxnK30Gr3vKa4FM/E0N5Pn0W/VnLvuIAS1qPEhwK
         Ie/Aimvh2DZcSx+bPuOi2ouLohkfUe5Ra+XiZsHs8tb+COrKl2bwlOnmodaiB0J6K9c6
         ET/vj1pDoMOIrNmfDcm3w5alS/+AR1FDHHbtBZmcP94yGN7AKA7PW9S82P9SraUYHDXn
         QtE2p2nWoAUqDHRIDn5M5S1z2M+WIct4McJY2FqZHNaol9lhInH9Twuo/CUTE1jr3V7Y
         jKNGVseIXya2p5B0PBguqJ+XS+cBDkNONPpvjrdvR12p+m7hWGQAvzIcB9K8jJLBiOWZ
         aXzg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of a13xp0p0v88@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=a13xp0p0v88@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q21sor13836957lji.10.2019.07.17.09.32.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jul 2019 09:32:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of a13xp0p0v88@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of a13xp0p0v88@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=a13xp0p0v88@gmail.com
X-Google-Smtp-Source: APXvYqw8/yzTJs6CxTi/F2Af1OajkefZ36GPQOQNQraarNA3wXnfgWI3z9FIK37oPgVQgrECoeTI2A==
X-Received: by 2002:a2e:7604:: with SMTP id r4mr21491517ljc.225.1563381121256;
        Wed, 17 Jul 2019 09:32:01 -0700 (PDT)
Received: from [192.168.42.115] ([213.87.160.6])
        by smtp.gmail.com with ESMTPSA id b17sm4573698ljf.34.2019.07.17.09.31.58
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 09:32:00 -0700 (PDT)
Reply-To: alex.popov@linux.com
To: Laura Abbott <labbott@redhat.com>, Sumit Semwal
 <sumit.semwal@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 arve@android.com, Todd Kjos <tkjos@android.com>,
 Martijn Coenen <maco@android.com>, Joel Fernandes <joel@joelfernandes.org>,
 Christian Brauner <christian@brauner.io>,
 Riley Andrews <riandrews@android.com>, devel@driverdev.osuosl.org,
 linaro-mm-sig@lists.linaro.org,
 linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
 dri-devel@lists.freedesktop.org, LKML <linux-kernel@vger.kernel.org>,
 Brian Starkey <brian.starkey@arm.com>,
 Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>,
 Benjamin Gaignard <benjamin.gaignard@linaro.org>,
 Linux-MM <linux-mm@kvack.org>, Dmitry Vyukov <dvyukov@google.com>,
 Andrey Konovalov <andreyknvl@google.com>, syzkaller@googlegroups.com
From: Alexander Popov <alex.popov@linux.com>
Subject: Limits for ION Memory Allocator
Openpgp: preference=signencrypt
Autocrypt: addr=alex.popov@linux.com; prefer-encrypt=mutual; keydata=
 mQINBFX15q4BEADZartsIW3sQ9R+9TOuCFRIW+RDCoBWNHhqDLu+Tzf2mZevVSF0D5AMJW4f
 UB1QigxOuGIeSngfmgLspdYe2Kl8+P8qyfrnBcS4hLFyLGjaP7UVGtpUl7CUxz2Hct3yhsPz
 ID/rnCSd0Q+3thrJTq44b2kIKqM1swt/F2Er5Bl0B4o5WKx4J9k6Dz7bAMjKD8pHZJnScoP4
 dzKPhrytN/iWM01eRZRc1TcIdVsRZC3hcVE6OtFoamaYmePDwWTRhmDtWYngbRDVGe3Tl8bT
 7BYN7gv7Ikt7Nq2T2TOfXEQqr9CtidxBNsqFEaajbFvpLDpUPw692+4lUbQ7FL0B1WYLvWkG
 cVysClEyX3VBSMzIG5eTF0Dng9RqItUxpbD317ihKqYL95jk6eK6XyI8wVOCEa1V3MhtvzUo
 WGZVkwm9eMVZ05GbhzmT7KHBEBbCkihS+TpVxOgzvuV+heCEaaxIDWY/k8u4tgbrVVk+tIVG
 99v1//kNLqd5KuwY1Y2/h2MhRrfxqGz+l/f/qghKh+1iptm6McN//1nNaIbzXQ2Ej34jeWDa
 xAN1C1OANOyV7mYuYPNDl5c9QrbcNGg3D6gOeGeGiMn11NjbjHae3ipH8MkX7/k8pH5q4Lhh
 Ra0vtJspeg77CS4b7+WC5jlK3UAKoUja3kGgkCrnfNkvKjrkEwARAQABtCZBbGV4YW5kZXIg
 UG9wb3YgPGFsZXgucG9wb3ZAbGludXguY29tPokCQAQTAQoAKgIbIwIeAQIXgAULCQgHAwUV
 CgkICwUWAgMBAAUJB8+UXAUCWgsUegIZAQAKCRCODp3rvH6PqqpOEACX+tXHOgMJ6fGxaNJZ
 HkKRFR/9AGP1bxp5QS528Sd6w17bMMQ87V5NSFUsTMPMcbIoO73DganKQ3nN6tW0ZvDTKpRt
 pBUCUP8KPqNvoSs3kkskaQgNQ3FXv46YqPZ7DoYj9HevY9NUyGLwCTEWD2ER5zKuNbI2ek82
 j4rwdqXn9kqqBf1ExAoEsszeNHzTKRl2d+bXuGDcOdpnOi7avoQfwi/O0oapR+goxz49Oeov
 YFf1EVaogHjDBREaqiqJ0MSKexfVBt8RD9ev9SGSIMcwfhgUHhMTX2JY/+6BXnUbzVcHD6HR
 EgqVGn/0RXfJIYmFsjH0Z6cHy34Vn+aqcGa8faztPnmkA/vNfhw8k5fEE7VlBqdEY8YeOiza
 hHdpaUi4GofNy/GoHIqpz16UulMjGB5SBzgsYKgCO+faNBrCcBrscWTl1aJfSNJvImuS1JhB
 EQnl/MIegxyBBRsH68x5BCffERo4FjaG0NDCmZLjXPOgMvl3vRywHLdDZThjAea3pwdGUq+W
 C77i7tnnUqgK7P9i+nEKwNWZfLpfjYgH5JE/jOgMf4tpHvO6fu4AnOffdz3kOxDyi+zFLVcz
 rTP5b46aVjI7D0dIDTIaCKUT+PfsLnJmP18x7dU/gR/XDcUaSEbWU3D9u61AvxP47g7tN5+a
 5pFIJhJ44JLk6I5H/bkCDQRV9eauARAArcUVf6RdT14hkm0zT5TPc/3BJc6PyAghV/iCoPm8
 kbzjKBIK80NvGodDeUV0MnQbX40jjFdSI0m96HNt86FtifQ3nwuW/BtS8dk8+lakRVwuTgMb
 hJWmXqKMFdVRCbjdyLbZWpdPip0WGND6p5i801xgPRmI8P6e5e4jBO4Cx1ToIFyJOzD/jvtb
 UhH9t5/naKUGa5BD9gSkguooXVOFvPdvKQKca19S7bb9hzjySh63H4qlbhUrG/7JGhX+Lr3g
 DwuAGrrFIV0FaVyIPGZ8U2fjLKpcBC7/lZJv0jRFpZ9CjHefILxt7NGxPB9hk2iDt2tE6jSl
 GNeloDYJUVItFmG+/giza2KrXmDEFKl+/mwfjRI/+PHR8PscWiB7S1zhsVus3DxhbM2mAK4x
 mmH4k0wNfgClh0Srw9zCU2CKJ6YcuRLi/RAAiyoxBb9wnSuQS5KkxoT32LRNwfyMdwlEtQGp
 WtC/vBI13XJVabx0Oalx7NtvRCcX1FX9rnKVjSFHX5YJ48heAd0dwRVmzOGL/EGywb1b9Q3O
 IWe9EFF8tmWV/JHs2thMz492qTHA5pm5JUsHQuZGBhBU+GqdOkdkFvujcNu4w7WyuEITBFAh
 5qDiGkvY9FU1OH0fWQqVU/5LHNizzIYN2KjU6529b0VTVGb4e/M0HglwtlWpkpfQzHMAEQEA
 AYkCJQQYAQIADwUCVfXmrgIbDAUJCWYBgAAKCRCODp3rvH6PqrZtEACKsd/UUtpKmy4mrZwl
 053nWp7+WCE+S9ke7CFytmXoMWf1CIrcQTk5cmdBmB4E0l3sr/DgKlJ8UrHTdRLcZZnbVqur
 +fnmVeQy9lqGkaIZvx/iXVYUqhT3+DNj9Zkjrynbe5pLsrGyxYWfsPRVL6J4mQatChadjuLw
 7/WC6PBmWkRA2SxUVpxFEZlirpbboYWLSXk9I3JmS5/iJ+P5kHYiB0YqYkd1twFXXxixv1GB
 Zi/idvWTK7x6/bUh0AAGTKc5zFhyR4DJRGROGlFTAYM3WDoa9XbrHXsggJDLNoPZJTj9DMww
 u28SzHLvR3t2pY1dT61jzKNDLoE3pjvzgLKF/Olif0t7+m0IPKY+8umZvUEhJ9CAUcoFPCfG
 tEbL6t1xrcsT7dsUhZpkIX0Qc77op8GHlfNd/N6wZUt19Vn9G8B6xrH+dinc0ylUc4+4yxt6
 6BsiEzma6Ah5jexChYIwaB5Oi21yjc6bBb4l6z01WWJQ052OGaOBzi+tS5iGmc5DWH4/pFqX
 OIkgJVVgjPv2y41qV66QJJEi2wT4WUKLY1zA9s6KXbt8dVSzJsNFvsrAoFdtzc8v6uqCo0/W
 f0Id8MBKoqN5FniTHWNxYX6b2dFwq8i5Rh6Oxc6q75Kg8279+co3/tLCkU6pGga28K7tUP2z
 h9AUWENlnWJX/YhP8IkCJQQYAQoADwIbDAUCWgsSOgUJB9eShwAKCRCODp3rvH6PqtoND/41
 ozCKAS4WWBBCU6AYLm2SoJ0EGhg1kIf9VMiqy5PKlSrAnW5yl4WJQcv5wER/7EzvZ49Gj8aG
 uRWfz3lyQU8dH2KG6KLilDFCZF0mViEo2C7O4QUx5xmbpMUq41fWjY947Xvd3QDisc1T1/7G
 uNBAALEZdqzwnKsT9G27e9Cd3AW3KsLAD4MhsALFARg6OuuwDCbLl6k5fu++26PEqORGtpJQ
 rRBWan9ZWb/Y57P126IVIylWiH6vt6iEPlaEHBU8H9+Z0WF6wJ5rNz9gR6GhZhmo1qsyNedD
 1HzOsXQhvCinsErpZs99VdZSF3d54dac8ypH4hvbjSmXZjY3Sblhyc6RLYlru5UXJFh7Hy+E
 TMuCg3hIVbdyFSDkvxVlvhHgUSf8+Uk3Ya4MO4a5l9ElUqxpSqYH7CvuwkG+mH5mN8tK3CCd
 +aKPCxUFfil62DfTa7YgLovr7sHQB+VMQkNDPXleC+amNqJb423L8M2sfCi9gw/lA1ha6q80
 ydgbcFEkNjqz4OtbrSwEHMy/ADsUWksYuzVbw7/pQTc6OAskESBr5igP7B/rIACUgiIjdOVB
 ktD1IQcezrDcuzVCIpuq8zC6LwLm7V1Tr6zfU9FWwnqzoQeQZH4QlP7MBuOeswCpxIl07mz9
 jXz/74kjFsyRgZA+d6a1pGtOwITEBxtxxg==
Message-ID: <3b922aa4-c6d4-e4a4-766d-f324ff77f7b5@linux.com>
Date: Wed, 17 Jul 2019 19:31:57 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello!

The syzkaller [1] has a trouble with fuzzing the Linux kernel with ION Memory
Allocator.

Syzkaller uses several methods [2] to limit memory consumption of the userspace
processes calling the syscalls for testing the kernel:
 - setrlimit(),
 - cgroups,
 - various sysctl.
But these methods don't work for ION Memory Allocator, so any userspace process
that has access to /dev/ion can bring the system to the out-of-memory state.

An example of a program doing that:


#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <linux/types.h>
#include <sys/ioctl.h>

#define ION_IOC_MAGIC		'I'
#define ION_IOC_ALLOC		_IOWR(ION_IOC_MAGIC, 0, \
				      struct ion_allocation_data)

struct ion_allocation_data {
	__u64 len;
	__u32 heap_id_mask;
	__u32 flags;
	__u32 fd;
	__u32 unused;
};

int main(void)
{
	unsigned long i = 0;
	int fd = -1;
	struct ion_allocation_data data = {
		.len = 0x13f65d8c,
		.heap_id_mask = 1,
		.flags = 0,
		.fd = -1,
		.unused = 0
	};

	fd = open("/dev/ion", 0);
	if (fd == -1) {
		perror("[-] open /dev/ion");
		return 1;
	}

	while (1) {
		printf("iter %lu\n", i);
		ioctl(fd, ION_IOC_ALLOC, &data);
		i++;
	}

	return 0;
}


I looked through the code of ion_alloc() and didn't find any limit checks.
Is it currently possible to limit ION kernel allocations for some process?

If not, is it a right idea to do that?
Thanks!

Best regards,
Alexander


[1]: https://github.com/google/syzkaller
[2]: https://github.com/google/syzkaller/blob/master/executor/common_linux.h

