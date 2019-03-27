Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAEDAC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 06:36:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C4D42075E
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 06:36:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C4D42075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB6516B0003; Wed, 27 Mar 2019 02:36:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8E096B0006; Wed, 27 Mar 2019 02:36:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A3EE6B0007; Wed, 27 Mar 2019 02:36:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4A3156B0003
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 02:36:41 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m31so6236088edm.4
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 23:36:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=IGSgYnXou/RBGvA6mnIJIA4AjlVL5IMIKpxYYCYDXUY=;
        b=jf+gwZtb0rSzpZYz2L5hkoQNU8TiyCvRp8OWfssP6nhc2Zaq059JuAt1KeaDfG707I
         3nBt26FcObWlCLMUPxHx9gieNNKyZvEnvz5TfZpk80cKi/KAaIFZ0hvqqWfyV6CZyW5P
         nqgUvBKWw+0QHKrNJbIlspTYtP2kLeKJbGwNTvtET4sBEKHnKa44i8YW5ifw64UkPffP
         RtahUIzoCbCauF2B+1bcwiroQumNT7fcAHqQMpcXL9UuwVVh5W0d9vcyW4XF1wOJSmUF
         SY/w7GuNmiY+zcpC/sj0BT4SA2MY89weZt5sWV1mv7aT4zmXAlDXd/UdFGSOoBT6JJoV
         OVYQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUZho//s1auMfZKfY6z2dWmWaI9yyQT1rgpjiZ+gxNMixacb6aW
	zJOcnBlNT2RJlU8wCRzjUFXFYO5ZRfI86BEIpPVw3dS2uXeclz+J+wmalugkwjPV2Ehbnp0gQ4E
	dJL8ps+DAntpI9W8egWwwGSj+nArSVgsJfaTSLDM/bTA3vlJHPLnZbO4qsLo+fHA=
X-Received: by 2002:a17:906:1103:: with SMTP id h3mr20000330eja.41.1553668600597;
        Tue, 26 Mar 2019 23:36:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwuu6pc87vaWadTiGLIm8oHQ6Cn/8XGQ+KCutQhsrdlM6RkH0UOaDfUq20BLbN8j9La4H9R
X-Received: by 2002:a17:906:1103:: with SMTP id h3mr20000271eja.41.1553668599294;
        Tue, 26 Mar 2019 23:36:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553668599; cv=none;
        d=google.com; s=arc-20160816;
        b=fMW2niIW/D+xlnKvnW1c61pkqwbuetGHX8QP95TtN1gQ9nrpsGjKksBW2vwD+pQvHt
         yNSgRTh5srZ1rHdpUgqramO2XKPdsF6PkqIxv07jsXhefaDWr3Gbp951moHxBDzi3IYI
         ix4/k4NaixSDqDJTBdB9ImRNQr9MeyPdxTJOWhVurbMicki3bxlCwrdn7iTOpR0J1WNl
         xqd+srtsrNBL11VogtptzYW0BvyguGCzJ/2CkwTqm0Ncnn1JWtyqpq1aMqBOvP6m5cF2
         R+yAoVRPwIb9K/Pkl1h3DDR2c9v5AZAZKnNg5ZhzC0Bw9j72jkXYt+RQHicv0uczGx2z
         PNKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=IGSgYnXou/RBGvA6mnIJIA4AjlVL5IMIKpxYYCYDXUY=;
        b=aoJ+2zHHAgnp98Jb77ygQYBlTPliKYUyP1b6vJoyOYbxx/OGzStieRuOFSCNxmOUdj
         w1AXGRQ2ME6PsYROxqmMF8MCgy3QinS7jN0eqp/Ra1wwhnTJMXja80m8lT/fRC7jGvP3
         AQw5DLlkjnPObPIOd49pT56OPpIMy9EySyoOS7CPtLc7Vzb16Y+SW2o3WVU5er9HZwDP
         jbICOjs6mbzy2tlmeEUxSKJ7OFZrRRKJf6hftymQJEjU6eC+sw6GYklEMnlvgQB7/wib
         KuaGmIVC1lo3u14hL9TutXTPNAGUM+1HadkpHWrKqhLDCde9BtyX4UPwSpF51ObrwT5m
         E6Rw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay11.mail.gandi.net (relay11.mail.gandi.net. [217.70.178.231])
        by mx.google.com with ESMTPS id w8si2950370edc.93.2019.03.26.23.36.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Mar 2019 23:36:39 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.231;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay11.mail.gandi.net (Postfix) with ESMTPSA id 78482100003;
	Wed, 27 Mar 2019 06:36:28 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: aneesh.kumar@linux.ibm.com,
	mpe@ellerman.id.au,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S . Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	"H . Peter Anvin" <hpa@zytor.com>,
	x86@kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org
Cc: Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v8 0/4] Fix free/allocation of runtime gigantic pages            
Date: Wed, 27 Mar 2019 02:36:22 -0400
Message-Id: <20190327063626.18421-1-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series fixes sh and sparc that did not advertise their gigantic page        
support and then were not able to allocate and free those pages at runtime.      
It renames MEMORY_ISOLATION && COMPACTION || CMA condition into the more         
accurate CONTIG_ALLOC, since it allows the definition of alloc_contig_range      
function.                                                                        
Finally, it then fixes the wrong definition of ARCH_HAS_GIGANTIC_PAGE config     
that, without MEMORY_ISOLATION && COMPACTION || CMA defined, did not allow       
architectures to free boottime allocated gigantic pages although unrelated.      
                                                                                 
Changes in v8:                                                                   
  This (hopefully last) version is rebased against v5.1-rc2 so that              
  it takes into account https://patchwork.ozlabs.org/patch/1047003/.             
  This version:                                                                  
  - factorizes gigantic_page_runtime_supported such as suggested                 
    by Christophe.                                                               
  - fix checkpath warning regarding the use of 'extern'                          
  - fix s390 build that does not include asm-generic/hugetlb.h                   
  And note that I did not add the reviewed-by and acked-by received in v6        
  since the patch differs a little.                                              
                                                                                 
Changes in v7:                                                                   
  I thought gigantic page support was settled at compile time, but Aneesh        
  and Michael have just come up with a patch proving me wrong for                
  powerpc: https://patchwork.ozlabs.org/patch/1047003/. So this version:         
  - reintroduces gigantic_page_supported renamed into                            
    gigantic_page_runtime_supported                                              
  - reintroduces gigantic page page support corresponding checks (not            
    everywhere though: set_max_huge_pages check was redundant with               
    __nr_hugepages_store_common)                                                 
  - introduces the possibility for arch to override this function                
    by using asm-generic/hugetlb.h current semantics although Aneesh             
    proposed something else.                                                     
                                                                                 
Changes in v6:                                                                   
- Remove unnecessary goto since the fallthrough path does the same and is        
  the 'normal' behaviour, as suggested by Dave Hensen                            
- Be more explicit in comment in set_max_huge_page: we return an error           
  if alloc_contig_range is not defined and the user tries to allocate a          
  gigantic page (we keep the same behaviour as before this patch), but we        
  now let her free boottime gigantic page, as suggested by Dave Hensen           
- Add Acked-by, thanks.                                                          
                                                                                 
Changes in v5:                                                                   
- Fix bug in previous version thanks to Mike Kravetz                             
- Fix block comments that did not respect coding style thanks to Dave Hensen     
- Define ARCH_HAS_GIGANTIC_PAGE only for sparc64 as advised by David Miller 
- Factorize "def_bool" and "depends on" thanks to Vlastimil Babka                
                                                                                 
Changes in v4 as suggested by Dave Hensen:                                       
- Split previous version into small patches                                      
- Do not compile alloc_gigantic** functions for architectures that do not        
  support those pages                                                            
- Define correct ARCH_HAS_GIGANTIC_PAGE in all arch that support them to avoid   
  useless runtime check                                                          
- Add comment in set_max_huge_pages to explain that freeing is possible even     
  without CONTIG_ALLOC defined                                                   
- Remove gigantic_page_supported function across all archs                       
                                                                                 
Changes in v3 as suggested by Vlastimil Babka and Dave Hansen:                   
- config definition was wrong and is now in mm/Kconfig                           
- COMPACTION_CORE was renamed in CONTIG_ALLOC                                    
                                                                                 
Changes in v2 as suggested by Vlastimil Babka:                                   
- Get rid of ARCH_HAS_GIGANTIC_PAGE                                              
- Get rid of architecture specific gigantic_page_supported                       
- Factorize CMA or (MEMORY_ISOLATION && COMPACTION) into COMPACTION_CORE 

Alexandre Ghiti (4):
  sh: Advertise gigantic page support
  sparc: Advertise gigantic page support
  mm: Simplify MEMORY_ISOLATION && COMPACTION || CMA into CONTIG_ALLOC
  hugetlb: allow to free gigantic pages regardless of the configuration

 arch/arm64/Kconfig                           |  2 +-
 arch/arm64/include/asm/hugetlb.h             |  4 --
 arch/powerpc/include/asm/book3s/64/hugetlb.h |  5 +-
 arch/powerpc/platforms/Kconfig.cputype       |  2 +-
 arch/s390/Kconfig                            |  2 +-
 arch/s390/include/asm/hugetlb.h              |  8 +--
 arch/sh/Kconfig                              |  1 +
 arch/sparc/Kconfig                           |  1 +
 arch/x86/Kconfig                             |  2 +-
 arch/x86/include/asm/hugetlb.h               |  4 --
 arch/x86/mm/hugetlbpage.c                    |  2 +-
 include/asm-generic/hugetlb.h                |  7 +++
 include/linux/gfp.h                          |  4 +-
 mm/Kconfig                                   |  3 ++
 mm/hugetlb.c                                 | 54 ++++++++++++++------
 mm/page_alloc.c                              |  7 ++-
 16 files changed, 67 insertions(+), 41 deletions(-)

-- 
2.20.1

